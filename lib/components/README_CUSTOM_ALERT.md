# CustomAlertDialog - Guide d'utilisation

## 📋 Description

`CustomAlertDialog` est un composant de popup personnalisé et élégant pour afficher des messages dans toute l'application. Il remplace les SnackBar par des popups plus visuels et professionnels.

## 🎨 Types de messages disponibles

- **Error** (Rouge) : Pour les erreurs
- **Success** (Vert) : Pour les succès
- **Warning** (Orange) : Pour les avertissements
- **Info** (Bleu) : Pour les informations

## 💻 Utilisation

### Méthode simple (recommandée)

```dart
import 'package:repartir_frontend/components/custom_alert_dialog.dart';

// Afficher une erreur
CustomAlertDialog.showError(
  context: context,
  message: 'Une erreur est survenue.',
  title: 'Erreur',
);

// Afficher un succès
CustomAlertDialog.showSuccess(
  context: context,
  message: 'Votre demande a été envoyée avec succès !',
  title: 'Succès',
);

// Afficher un avertissement
CustomAlertDialog.showWarning(
  context: context,
  message: 'Veuillez remplir tous les champs.',
  title: 'Attention',
);

// Afficher une information
CustomAlertDialog.showInfo(
  context: context,
  message: 'Votre profil a été mis à jour.',
  title: 'Information',
);
```

### Méthode avancée

```dart
CustomAlertDialog.show(
  context: context,
  title: 'Titre personnalisé',
  message: 'Message personnalisé',
  type: AlertType.error, // ou success, warning, info
  buttonText: 'Fermer',
  onConfirm: () {
    // Action à exécuter lors du clic sur le bouton
    Navigator.pop(context);
  },
  showCancelButton: true, // Afficher un bouton "Annuler"
);
```

## 📝 Exemples d'utilisation

### Validation de formulaire

```dart
if (_formKey.currentState?.validate() != true) {
  CustomAlertDialog.showError(
    context: context,
    message: "Veuillez remplir correctement tous les champs obligatoires.",
    title: "Formulaire incomplet",
  );
  return;
}
```

### Erreur de connexion

```dart
try {
  await authService.login(email, password);
} catch (e) {
  CustomAlertDialog.showError(
    context: context,
    message: 'Email ou mot de passe incorrect.',
    title: 'Erreur de connexion',
  );
}
```

### Succès d'opération

```dart
try {
  await service.createItem(data);
  CustomAlertDialog.showSuccess(
    context: context,
    message: 'Votre demande a été créée avec succès !',
    title: 'Succès',
    onConfirm: () {
      Navigator.pop(context);
    },
  );
} catch (e) {
  CustomAlertDialog.showError(
    context: context,
    message: 'Une erreur est survenue.',
    title: 'Erreur',
  );
}
```

### Avertissement avec confirmation

```dart
CustomAlertDialog.showWarning(
  context: context,
  message: 'Êtes-vous sûr de vouloir supprimer cet élément ?',
  title: 'Confirmation',
  showCancelButton: true,
  onConfirm: () {
    // Action de suppression
    deleteItem();
    Navigator.pop(context);
  },
);
```

## 🔄 Migration depuis SnackBar

**Avant :**
```dart
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Message d\'erreur'),
    backgroundColor: Colors.red,
  ),
);
```

**Après :**
```dart
CustomAlertDialog.showError(
  context: context,
  message: 'Message d\'erreur',
  title: 'Erreur',
);
```

## ✨ Avantages

- ✅ Interface plus élégante et professionnelle
- ✅ Messages plus visibles (popup au centre)
- ✅ Icônes contextuelles selon le type de message
- ✅ Cohérence visuelle dans toute l'application
- ✅ Facile à utiliser avec des méthodes helper
- ✅ Personnalisable (boutons, actions, etc.)


