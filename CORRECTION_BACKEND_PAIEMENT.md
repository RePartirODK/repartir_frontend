# 🔧 Correction Backend - Système de Paiement

## ❌ Problème Actuel

**Erreur** : `Check constraint 'paiement_chk_1' is violated`

Cette erreur se produit lors de la création d'un paiement direct (sans parrainage). La contrainte vérifie probablement qu'un paiement doit avoir soit un `id_parrainage`, soit un autre critère, ce qui empêche les paiements directs.

---

## ✅ Solution Backend à Appliquer

### 1️⃣ Vérifier la Contrainte dans la Base de Données

Exécutez cette requête SQL pour voir la définition de la contrainte :

```sql
-- Pour MySQL/MariaDB
SHOW CREATE TABLE paiement;

-- Pour PostgreSQL
SELECT constraint_name, check_clause 
FROM information_schema.check_constraints 
WHERE constraint_name = 'paiement_chk_1';
```

### 2️⃣ Corriger la Contrainte

La contrainte devrait probablement vérifier que :
- Si `id_parrainage` est NULL, c'est un paiement direct → OK
- Si `id_parrainage` est NOT NULL, c'est un paiement via parrainage → OK

**Supprimez l'ancienne contrainte et créez-en une correcte** :

```sql
-- Supprimer l'ancienne contrainte
ALTER TABLE paiement DROP CONSTRAINT paiement_chk_1;

-- Option 1 : Aucune contrainte (le plus simple)
-- Permet les paiements directs ET via parrainage

-- Option 2 : Contrainte simple
ALTER TABLE paiement 
ADD CONSTRAINT paiement_chk_1 
CHECK (montant > 0);

-- Option 3 : Contrainte complexe (si nécessaire)
-- Par exemple : si id_parrainage est NULL, alors id_jeune NOT NULL
ALTER TABLE paiement 
ADD CONSTRAINT paiement_chk_1 
CHECK (
    (id_parrainage IS NULL AND id_jeune IS NOT NULL) OR 
    (id_parrainage IS NOT NULL)
);
```

---

## 📧 Génération et Envoi de Reçus

### 3️⃣ Ajouter la Génération de Reçu PDF

#### A. Ajouter la dépendance iText dans `pom.xml`

```xml
<dependency>
    <groupId>com.itextpdf</groupId>
    <artifactId>itext7-core</artifactId>
    <version>7.2.5</version>
    <type>pom</type>
</dependency>
```

#### B. Créer le Service de Génération de Reçu

```java
package com.example.repartir_backend.services;

import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.example.repartir_backend.entities.Paiement;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.format.DateTimeFormatter;

@Service
@RequiredArgsConstructor
public class RecuPaiementService {

    public byte[] genererRecuPDF(Paiement paiement) throws Exception {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        PdfWriter writer = new PdfWriter(baos);
        PdfDocument pdf = new PdfDocument(writer);
        Document document = new Document(pdf);

        // En-tête
        Paragraph header = new Paragraph("REÇU DE PAIEMENT")
                .setFontSize(20)
                .setBold()
                .setTextAlignment(TextAlignment.CENTER);
        document.add(header);

        document.add(new Paragraph("\n"));

        // Informations du reçu
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        
        document.add(new Paragraph("Référence : " + paiement.getReference()).setBold());
        document.add(new Paragraph("Date : " + paiement.getDate().format(formatter)));
        document.add(new Paragraph("\n"));

        // Détails
        Table table = new Table(2);
        table.addCell("Bénéficiaire");
        table.addCell(paiement.getJeune().getUtilisateur().getNom() + " " + 
                      paiement.getJeune().getUtilisateur().getPrenom());
        
        table.addCell("Formation");
        table.addCell(paiement.getInscriptionFormation().getFormation().getTitre());
        
        table.addCell("Montant");
        table.addCell(paiement.getMontant() + " FCFA");
        
        table.addCell("Statut");
        table.addCell(paiement.getStatus().toString());
        
        document.add(table);

        document.add(new Paragraph("\n\n"));
        document.add(new Paragraph("Ce reçu atteste que le paiement a été validé par l'administration.")
                .setTextAlignment(TextAlignment.CENTER)
                .setItalic());

        document.close();
        return baos.toByteArray();
    }
}
```

#### C. Modifier le Service Mail pour Envoyer des Pièces Jointes

Ajoutez cette méthode dans `MailSendServices` :

```java
public void envoiMimeMessageAvecPieceJointe(String to, String sujet, String htmlContent, 
                                             byte[] attachmentData, String attachmentName) 
        throws MessagingException {
    MimeMessage mimeMailMessage = javaMailSender.createMimeMessage();
    MimeMessageHelper helper = new MimeMessageHelper(mimeMailMessage, true, "UTF-8");
    
    helper.setTo(to);
    helper.setSubject(sujet);
    helper.setText(htmlContent, true);
    
    // Ajouter la pièce jointe
    helper.addAttachment(attachmentName, new ByteArrayResource(attachmentData));
    
    javaMailSender.send(mimeMailMessage);
}
```

**N'oubliez pas d'importer** :
```java
import org.springframework.core.io.ByteArrayResource;
```

---

### 4️⃣ Modifier la Méthode `validerPaiement()`

```java
@Transactional
public String validerPaiement(int idPaiement) throws Exception {
    Paiement paiement = paiementRepository.findById(idPaiement)
            .orElseThrow(() -> new EntityNotFoundException("Paiement introuvable"));

    paiement.setStatus(StatutPaiement.VALIDE);
    paiementRepository.save(paiement);

    InscriptionFormation inscription = paiement.getInscriptionFormation();
    double totalValide = paiementRepository.findByInscriptionFormationAndStatus(inscription, Etat.VALIDE)
            .stream().mapToDouble(Paiement::getMontant).sum();

    if (totalValide >= inscription.getFormation().getCout()) {
        inscription.setStatus(Etat.VALIDE);
        inscriptionFormationRepository.save(inscription);
    }

    // NOUVEAU : Générer le reçu PDF
    byte[] recuPdf = recuPaiementService.genererRecuPDF(paiement);

    // NOUVEAU : Envoyer l'email avec le reçu
    String emailContent = genererEmailValidation(paiement);
    mailSendServices.envoiMimeMessageAvecPieceJointe(
        paiement.getJeune().getUtilisateur().getEmail(),
        "Paiement validé - Reçu",
        emailContent,
        recuPdf,
        "recu_" + paiement.getReference() + ".pdf"
    );

    return "Paiement validé. Total payé : " + totalValide + "/" + inscription.getFormation().getCout();
}

private String genererEmailValidation(Paiement paiement) {
    return String.format("""
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <div style="background: #f0f8ff; padding: 20px; border-radius: 10px;">
                <h2 style="color: #1a73e8;">✅ Paiement Validé</h2>
                <p>Bonjour <strong>%s</strong>,</p>
                <p>Votre paiement de <strong>%s FCFA</strong> pour la formation 
                   <strong>%s</strong> a été validé avec succès.</p>
                <p><strong>Référence :</strong> %s</p>
                <p>Vous trouverez votre reçu en pièce jointe de cet email.</p>
                <p style="margin-top: 20px;">Cordialement,<br>L'équipe RePartir</p>
            </div>
        </body>
        </html>
        """,
        paiement.getJeune().getUtilisateur().getNom(),
        paiement.getMontant(),
        paiement.getInscriptionFormation().getFormation().getTitre(),
        paiement.getReference()
    );
}
```

### 5️⃣ Modifier la Méthode `refuserPaiement()`

```java
@Transactional
public String refuserPaiement(int idPaiement) throws Exception {
    Paiement paiement = paiementRepository.findById(idPaiement)
            .orElseThrow(() -> new EntityNotFoundException("Paiement introuvable"));

    paiement.setStatus(StatutPaiement.REFUSE);
    paiementRepository.save(paiement);

    // NOUVEAU : Envoyer l'email de refus
    String emailContent = genererEmailRefus(paiement);
    mailSendServices.envoiMimeMessage(
        paiement.getJeune().getUtilisateur().getEmail(),
        "Paiement refusé",
        emailContent
    );

    return "Paiement refusé.";
}

private String genererEmailRefus(Paiement paiement) {
    return String.format("""
        <html>
        <body style="font-family: Arial, sans-serif; padding: 20px;">
            <div style="background: #ffe0e0; padding: 20px; border-radius: 10px;">
                <h2 style="color: #d32f2f;">❌ Paiement Refusé</h2>
                <p>Bonjour <strong>%s</strong>,</p>
                <p>Nous sommes au regret de vous informer que votre paiement de 
                   <strong>%s FCFA</strong> pour la formation <strong>%s</strong> 
                   a été refusé.</p>
                <p><strong>Référence :</strong> %s</p>
                <p>Veuillez contacter l'administration pour plus d'informations.</p>
                <p style="margin-top: 20px;">Cordialement,<br>L'équipe RePartir</p>
            </div>
        </body>
        </html>
        """,
        paiement.getJeune().getUtilisateur().getNom(),
        paiement.getMontant(),
        paiement.getInscriptionFormation().getFormation().getTitre(),
        paiement.getReference()
    );
}
```

### 6️⃣ Injecter les Dépendances dans `PaiementServices`

```java
@Service
@RequiredArgsConstructor
public class PaiementServices {
    private final PaiementRepository paiementRepository;
    private final InscriptionFormationRepository inscriptionFormationRepository;
    private final ParrainageRepository parrainageRepository;
    private final JeuneRepository jeuneRepository;
    private final MailSendServices mailSendServices;
    private final RecuPaiementService recuPaiementService; // NOUVEAU
    
    // ... reste du code
}
```

---

## 🎯 Checklist Finale

- [ ] Corriger la contrainte `paiement_chk_1` dans la base de données
- [ ] Ajouter la dépendance iText dans `pom.xml`
- [ ] Créer `RecuPaiementService` pour générer les PDF
- [ ] Ajouter la méthode `envoiMimeMessageAvecPieceJointe()` dans `MailSendServices`
- [ ] Modifier `validerPaiement()` pour générer et envoyer le reçu
- [ ] Modifier `refuserPaiement()` pour envoyer l'email de notification
- [ ] Tester la création d'un paiement direct (sans parrainage)
- [ ] Tester la validation d'un paiement (vérifier l'email + PDF)
- [ ] Tester le refus d'un paiement (vérifier l'email)

---

## 🧪 Tests à Effectuer

1. **Créer un paiement direct** :
   ```bash
   POST /api/paiements/creer
   {
     "idJeune": 1,
     "idInscription": 5,
     "montant": 8999
   }
   ```
   ✅ Devrait fonctionner sans erreur

2. **Valider un paiement** :
   ```bash
   PUT /api/paiements/valider/1
   ```
   ✅ Le jeune devrait recevoir un email avec le reçu PDF en pièce jointe

3. **Refuser un paiement** :
   ```bash
   PUT /api/paiements/refuser/2
   ```
   ✅ Le jeune devrait recevoir un email de notification

---

**Auteur** : Système de Paiement RePartir  
**Date** : 2025-11-13


