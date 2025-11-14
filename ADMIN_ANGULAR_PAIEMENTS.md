# 🎨 Interface Admin Angular - Gestion des Paiements

## 📋 Vue d'Ensemble

Créer une interface admin complète pour gérer les paiements des jeunes avec possibilité de **valider** ou **refuser** les paiements en attente.

---

## 🗂️ Structure des Fichiers à Créer

```
src/app/
├── models/
│   ├── paiement.model.ts
│   └── statut-paiement.enum.ts
├── services/
│   └── paiement.service.ts
└── pages/admin/
    └── paiements/
        ├── paiements.component.ts
        ├── paiements.component.html
        ├── paiements.component.scss
        ├── validation-dialog/
        │   ├── validation-dialog.component.ts
        │   ├── validation-dialog.component.html
        │   └── validation-dialog.component.scss
        └── refus-dialog/
            ├── refus-dialog.component.ts
            ├── refus-dialog.component.html
            └── refus-dialog.component.scss
```

---

## 📦 1. Modèles TypeScript

### `statut-paiement.enum.ts`

```typescript
export enum StatutPaiement {
  VALIDE = 'VALIDE',
  EN_ATTENTE = 'EN_ATTENTE',
  REFUSE = 'REFUSE',
  A_REMBOURSE = 'A_REMBOURSE',
  REMBOURSE = 'REMBOURSE'
}

export class StatutPaiementHelper {
  static getLabel(statut: StatutPaiement): string {
    const labels = {
      [StatutPaiement.VALIDE]: 'Validé',
      [StatutPaiement.EN_ATTENTE]: 'En attente',
      [StatutPaiement.REFUSE]: 'Refusé',
      [StatutPaiement.A_REMBOURSE]: 'À rembourser',
      [StatutPaiement.REMBOURSE]: 'Remboursé'
    };
    return labels[statut] || statut;
  }

  static getColor(statut: StatutPaiement): string {
    const colors = {
      [StatutPaiement.VALIDE]: 'success',
      [StatutPaiement.EN_ATTENTE]: 'warn',
      [StatutPaiement.REFUSE]: 'error',
      [StatutPaiement.A_REMBOURSE]: 'primary',
      [StatutPaiement.REMBOURSE]: 'accent'
    };
    return colors[statut] || 'default';
  }

  static getIcon(statut: StatutPaiement): string {
    const icons = {
      [StatutPaiement.VALIDE]: 'check_circle',
      [StatutPaiement.EN_ATTENTE]: 'hourglass_empty',
      [StatutPaiement.REFUSE]: 'cancel',
      [StatutPaiement.A_REMBOURSE]: 'payment',
      [StatutPaiement.REMBOURSE]: 'done_all'
    };
    return icons[statut] || 'help';
  }
}
```

### `paiement.model.ts`

```typescript
import { StatutPaiement } from './statut-paiement.enum';

export interface Paiement {
  id: number;
  montant: number;
  reference: string;
  date: Date;
  status: StatutPaiement;
  idJeune: number;
  idParrainage?: number;
  idFormation: number;
  
  // Informations enrichies (depuis le backend)
  nomJeune?: string;
  prenomJeune?: string;
  emailJeune?: string;
  titreFormation?: string;
}

export interface PaiementFilters {
  status?: StatutPaiement;
  dateDebut?: Date;
  dateFin?: Date;
  searchTerm?: string;
}
```

---

## 🔌 2. Service Angular

### `paiement.service.ts`

```typescript
import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';
import { Paiement, PaiementFilters } from '../models/paiement.model';

@Injectable({
  providedIn: 'root'
})
export class PaiementService {
  private apiUrl = `${environment.apiBaseUrl}/paiements`;

  constructor(private http: HttpClient) {}

  /**
   * Récupérer tous les paiements
   */
  getAllPaiements(filters?: PaiementFilters): Observable<Paiement[]> {
    let params = new HttpParams();
    
    if (filters?.status) {
      params = params.set('status', filters.status);
    }
    if (filters?.dateDebut) {
      params = params.set('dateDebut', filters.dateDebut.toISOString());
    }
    if (filters?.dateFin) {
      params = params.set('dateFin', filters.dateFin.toISOString());
    }

    return this.http.get<Paiement[]>(`${this.apiUrl}/tous`, { params });
  }

  /**
   * Valider un paiement
   */
  validerPaiement(idPaiement: number): Observable<string> {
    return this.http.put<string>(`${this.apiUrl}/valider/${idPaiement}`, {});
  }

  /**
   * Refuser un paiement
   */
  refuserPaiement(idPaiement: number, motif?: string): Observable<string> {
    return this.http.put<string>(`${this.apiUrl}/refuser/${idPaiement}`, 
      { motif: motif || 'Non spécifié' }
    );
  }

  /**
   * Récupérer les paiements d'un jeune
   */
  getPaiementsByJeune(idJeune: number): Observable<Paiement[]> {
    return this.http.get<Paiement[]>(`${this.apiUrl}/jeunes/${idJeune}`);
  }

  /**
   * Récupérer les paiements d'une inscription
   */
  getPaiementsByInscription(idInscription: number): Observable<Paiement[]> {
    return this.http.get<Paiement[]>(`${this.apiUrl}/inscription/${idInscription}`);
  }
}
```

---

## 🎨 3. Component Principal

### `paiements.component.ts`

```typescript
import { Component, OnInit, ViewChild } from '@angular/core';
import { MatTableDataSource } from '@angular/material/table';
import { MatPaginator } from '@angular/material/paginator';
import { MatSort } from '@angular/material/sort';
import { MatDialog } from '@angular/material/dialog';
import { MatSnackBar } from '@angular/material/snack-bar';
import { PaiementService } from '../../../services/paiement.service';
import { Paiement, PaiementFilters } from '../../../models/paiement.model';
import { StatutPaiement, StatutPaiementHelper } from '../../../models/statut-paiement.enum';
import { ValidationDialogComponent } from './validation-dialog/validation-dialog.component';
import { RefusDialogComponent } from './refus-dialog/refus-dialog.component';

@Component({
  selector: 'app-paiements',
  templateUrl: './paiements.component.html',
  styleUrls: ['./paiements.component.scss']
})
export class PaiementsComponent implements OnInit {
  displayedColumns: string[] = [
    'reference', 
    'date', 
    'jeune', 
    'formation', 
    'montant', 
    'status', 
    'actions'
  ];
  
  dataSource = new MatTableDataSource<Paiement>();
  statutPaiement = StatutPaiement;
  statutHelper = StatutPaiementHelper;
  
  loading = false;
  filters: PaiementFilters = {};
  selectedStatus: StatutPaiement | 'TOUS' = 'TOUS';

  @ViewChild(MatPaginator) paginator!: MatPaginator;
  @ViewChild(MatSort) sort!: MatSort;

  constructor(
    private paiementService: PaiementService,
    private dialog: MatDialog,
    private snackBar: MatSnackBar
  ) {}

  ngOnInit(): void {
    this.loadPaiements();
  }

  ngAfterViewInit(): void {
    this.dataSource.paginator = this.paginator;
    this.dataSource.sort = this.sort;
  }

  loadPaiements(): void {
    this.loading = true;
    
    const filters: PaiementFilters = {};
    if (this.selectedStatus !== 'TOUS') {
      filters.status = this.selectedStatus as StatutPaiement;
    }

    this.paiementService.getAllPaiements(filters).subscribe({
      next: (paiements) => {
        this.dataSource.data = paiements;
        this.loading = false;
      },
      error: (error) => {
        console.error('Erreur lors du chargement des paiements', error);
        this.showSnackBar('Erreur lors du chargement des paiements', 'error');
        this.loading = false;
      }
    });
  }

  applyFilter(event: Event): void {
    const filterValue = (event.target as HTMLInputElement).value;
    this.dataSource.filter = filterValue.trim().toLowerCase();
  }

  onStatusFilterChange(): void {
    this.loadPaiements();
  }

  validerPaiement(paiement: Paiement): void {
    const dialogRef = this.dialog.open(ValidationDialogComponent, {
      width: '500px',
      data: paiement
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result === true) {
        this.loading = true;
        this.paiementService.validerPaiement(paiement.id).subscribe({
          next: () => {
            this.showSnackBar('Paiement validé avec succès', 'success');
            this.loadPaiements();
          },
          error: (error) => {
            console.error('Erreur lors de la validation', error);
            this.showSnackBar('Erreur lors de la validation du paiement', 'error');
            this.loading = false;
          }
        });
      }
    });
  }

  refuserPaiement(paiement: Paiement): void {
    const dialogRef = this.dialog.open(RefusDialogComponent, {
      width: '500px',
      data: paiement
    });

    dialogRef.afterClosed().subscribe(result => {
      if (result) {
        this.loading = true;
        this.paiementService.refuserPaiement(paiement.id, result.motif).subscribe({
          next: () => {
            this.showSnackBar('Paiement refusé', 'success');
            this.loadPaiements();
          },
          error: (error) => {
            console.error('Erreur lors du refus', error);
            this.showSnackBar('Erreur lors du refus du paiement', 'error');
            this.loading = false;
          }
        });
      }
    });
  }

  private showSnackBar(message: string, type: 'success' | 'error'): void {
    this.snackBar.open(message, 'Fermer', {
      duration: 5000,
      panelClass: type === 'success' ? 'snackbar-success' : 'snackbar-error'
    });
  }

  canValidate(paiement: Paiement): boolean {
    return paiement.status === StatutPaiement.EN_ATTENTE;
  }

  canRefuse(paiement: Paiement): boolean {
    return paiement.status === StatutPaiement.EN_ATTENTE;
  }
}
```

### `paiements.component.html`

```html
<div class="paiements-container">
  <mat-card>
    <mat-card-header>
      <mat-card-title>
        <mat-icon>payment</mat-icon>
        Gestion des Paiements
      </mat-card-title>
    </mat-card-header>

    <mat-card-content>
      <!-- Filtres -->
      <div class="filters-row">
        <mat-form-field appearance="outline" class="filter-field">
          <mat-label>Rechercher</mat-label>
          <input matInput (keyup)="applyFilter($event)" placeholder="Référence, jeune..." />
          <mat-icon matSuffix>search</mat-icon>
        </mat-form-field>

        <mat-form-field appearance="outline" class="filter-field">
          <mat-label>Statut</mat-label>
          <mat-select [(ngModel)]="selectedStatus" (selectionChange)="onStatusFilterChange()">
            <mat-option value="TOUS">Tous</mat-option>
            <mat-option value="EN_ATTENTE">En attente</mat-option>
            <mat-option value="VALIDE">Validé</mat-option>
            <mat-option value="REFUSE">Refusé</mat-option>
            <mat-option value="A_REMBOURSE">À rembourser</mat-option>
            <mat-option value="REMBOURSE">Remboursé</mat-option>
          </mat-select>
        </mat-form-field>

        <button mat-raised-button color="primary" (click)="loadPaiements()">
          <mat-icon>refresh</mat-icon>
          Actualiser
        </button>
      </div>

      <!-- Loader -->
      <div class="loader-container" *ngIf="loading">
        <mat-spinner></mat-spinner>
      </div>

      <!-- Table -->
      <div class="table-container" *ngIf="!loading">
        <table mat-table [dataSource]="dataSource" matSort class="paiements-table">
          
          <!-- Référence -->
          <ng-container matColumnDef="reference">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Référence</th>
            <td mat-cell *matCellDef="let paiement">
              <strong class="reference">{{ paiement.reference }}</strong>
            </td>
          </ng-container>

          <!-- Date -->
          <ng-container matColumnDef="date">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Date</th>
            <td mat-cell *matCellDef="let paiement">
              {{ paiement.date | date: 'dd/MM/yyyy HH:mm' }}
            </td>
          </ng-container>

          <!-- Jeune -->
          <ng-container matColumnDef="jeune">
            <th mat-header-cell *matHeaderCellDef>Jeune</th>
            <td mat-cell *matCellDef="let paiement">
              {{ paiement.nomJeune }} {{ paiement.prenomJeune }}
              <br>
              <small class="email">{{ paiement.emailJeune }}</small>
            </td>
          </ng-container>

          <!-- Formation -->
          <ng-container matColumnDef="formation">
            <th mat-header-cell *matHeaderCellDef>Formation</th>
            <td mat-cell *matCellDef="let paiement">
              {{ paiement.titreFormation }}
            </td>
          </ng-container>

          <!-- Montant -->
          <ng-container matColumnDef="montant">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Montant</th>
            <td mat-cell *matCellDef="let paiement">
              <strong class="montant">{{ paiement.montant | number: '1.0-0' }} FCFA</strong>
            </td>
          </ng-container>

          <!-- Statut -->
          <ng-container matColumnDef="status">
            <th mat-header-cell *matHeaderCellDef mat-sort-header>Statut</th>
            <td mat-cell *matCellDef="let paiement">
              <mat-chip [color]="statutHelper.getColor(paiement.status)" selected>
                <mat-icon>{{ statutHelper.getIcon(paiement.status) }}</mat-icon>
                {{ statutHelper.getLabel(paiement.status) }}
              </mat-chip>
            </td>
          </ng-container>

          <!-- Actions -->
          <ng-container matColumnDef="actions">
            <th mat-header-cell *matHeaderCellDef>Actions</th>
            <td mat-cell *matCellDef="let paiement">
              <button 
                mat-icon-button 
                color="primary" 
                [disabled]="!canValidate(paiement)"
                (click)="validerPaiement(paiement)"
                matTooltip="Valider">
                <mat-icon>check_circle</mat-icon>
              </button>
              <button 
                mat-icon-button 
                color="warn" 
                [disabled]="!canRefuse(paiement)"
                (click)="refuserPaiement(paiement)"
                matTooltip="Refuser">
                <mat-icon>cancel</mat-icon>
              </button>
            </td>
          </ng-container>

          <tr mat-header-row *matHeaderRowDef="displayedColumns"></tr>
          <tr mat-row *matRowDef="let row; columns: displayedColumns;"></tr>

          <!-- Message si pas de données -->
          <tr class="mat-row" *matNoDataRow>
            <td class="mat-cell" [attr.colspan]="displayedColumns.length">
              <div class="no-data">
                <mat-icon>inbox</mat-icon>
                <p>Aucun paiement trouvé</p>
              </div>
            </td>
          </tr>
        </table>

        <mat-paginator 
          [pageSizeOptions]="[10, 25, 50, 100]" 
          showFirstLastButtons>
        </mat-paginator>
      </div>
    </mat-card-content>
  </mat-card>
</div>
```

### `paiements.component.scss`

```scss
.paiements-container {
  padding: 20px;

  mat-card {
    mat-card-header {
      mat-card-title {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 24px;
        font-weight: bold;
        color: #1976d2;
      }
    }

    mat-card-content {
      margin-top: 20px;
    }
  }

  .filters-row {
    display: flex;
    gap: 16px;
    margin-bottom: 20px;
    align-items: center;

    .filter-field {
      flex: 1;
      max-width: 300px;
    }
  }

  .loader-container {
    display: flex;
    justify-content: center;
    padding: 40px;
  }

  .table-container {
    overflow-x: auto;
  }

  .paiements-table {
    width: 100%;

    .reference {
      color: #1976d2;
      font-family: monospace;
    }

    .email {
      color: #757575;
      font-size: 12px;
    }

    .montant {
      color: #4caf50;
      font-size: 16px;
    }

    mat-chip {
      mat-icon {
        font-size: 18px;
        height: 18px;
        width: 18px;
        margin-right: 4px;
      }
    }

    .no-data {
      text-align: center;
      padding: 40px;
      color: #757575;

      mat-icon {
        font-size: 48px;
        height: 48px;
        width: 48px;
        opacity: 0.5;
      }

      p {
        margin-top: 16px;
        font-size: 16px;
      }
    }
  }
}

// Snackbar styles
::ng-deep {
  .snackbar-success {
    background-color: #4caf50 !important;
    color: white !important;
  }

  .snackbar-error {
    background-color: #f44336 !important;
    color: white !important;
  }
}
```

---

## 🔔 4. Dialogues de Validation et Refus

### `validation-dialog.component.ts`

```typescript
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Paiement } from '../../../../models/paiement.model';

@Component({
  selector: 'app-validation-dialog',
  templateUrl: './validation-dialog.component.html',
  styleUrls: ['./validation-dialog.component.scss']
})
export class ValidationDialogComponent {
  constructor(
    public dialogRef: MatDialogRef<ValidationDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public paiement: Paiement
  ) {}

  onConfirm(): void {
    this.dialogRef.close(true);
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }
}
```

### `validation-dialog.component.html`

```html
<h2 mat-dialog-title>
  <mat-icon color="primary">check_circle</mat-icon>
  Valider le paiement
</h2>

<mat-dialog-content>
  <div class="dialog-content">
    <p>Êtes-vous sûr de vouloir valider ce paiement ?</p>
    
    <mat-card class="info-card">
      <mat-card-content>
        <div class="info-row">
          <span class="label">Référence :</span>
          <span class="value">{{ paiement.reference }}</span>
        </div>
        <div class="info-row">
          <span class="label">Jeune :</span>
          <span class="value">{{ paiement.nomJeune }} {{ paiement.prenomJeune }}</span>
        </div>
        <div class="info-row">
          <span class="label">Montant :</span>
          <span class="value montant">{{ paiement.montant | number: '1.0-0' }} FCFA</span>
        </div>
      </mat-card-content>
    </mat-card>

    <mat-card class="warning-card">
      <mat-card-content>
        <mat-icon>info</mat-icon>
        <p>Un reçu sera automatiquement généré et envoyé au jeune par email.</p>
      </mat-card-content>
    </mat-card>
  </div>
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button (click)="onCancel()">Annuler</button>
  <button mat-raised-button color="primary" (click)="onConfirm()">
    <mat-icon>check</mat-icon>
    Valider
  </button>
</mat-dialog-actions>
```

### `refus-dialog.component.ts`

```typescript
import { Component, Inject } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material/dialog';
import { Paiement } from '../../../../models/paiement.model';

@Component({
  selector: 'app-refus-dialog',
  templateUrl: './refus-dialog.component.html',
  styleUrls: ['./refus-dialog.component.scss']
})
export class RefusDialogComponent {
  refusForm: FormGroup;

  constructor(
    public dialogRef: MatDialogRef<RefusDialogComponent>,
    @Inject(MAT_DIALOG_DATA) public paiement: Paiement,
    private fb: FormBuilder
  ) {
    this.refusForm = this.fb.group({
      motif: ['', [Validators.required, Validators.minLength(10)]]
    });
  }

  onConfirm(): void {
    if (this.refusForm.valid) {
      this.dialogRef.close(this.refusForm.value);
    }
  }

  onCancel(): void {
    this.dialogRef.close();
  }
}
```

### `refus-dialog.component.html`

```html
<h2 mat-dialog-title>
  <mat-icon color="warn">cancel</mat-icon>
  Refuser le paiement
</h2>

<mat-dialog-content>
  <div class="dialog-content">
    <p>Êtes-vous sûr de vouloir refuser ce paiement ?</p>
    
    <mat-card class="info-card">
      <mat-card-content>
        <div class="info-row">
          <span class="label">Référence :</span>
          <span class="value">{{ paiement.reference }}</span>
        </div>
        <div class="info-row">
          <span class="label">Jeune :</span>
          <span class="value">{{ paiement.nomJeune }} {{ paiement.prenomJeune }}</span>
        </div>
        <div class="info-row">
          <span class="label">Montant :</span>
          <span class="value montant">{{ paiement.montant | number: '1.0-0' }} FCFA</span>
        </div>
      </mat-card-content>
    </mat-card>

    <form [formGroup]="refusForm">
      <mat-form-field appearance="outline" class="full-width">
        <mat-label>Motif du refus</mat-label>
        <textarea 
          matInput 
          formControlName="motif"
          rows="4"
          placeholder="Expliquez pourquoi ce paiement est refusé..."
          required>
        </textarea>
        <mat-hint>Le jeune recevra ce motif par email</mat-hint>
        <mat-error *ngIf="refusForm.get('motif')?.hasError('required')">
          Le motif est obligatoire
        </mat-error>
        <mat-error *ngIf="refusForm.get('motif')?.hasError('minlength')">
          Minimum 10 caractères
        </mat-error>
      </mat-form-field>
    </form>

    <mat-card class="warning-card error">
      <mat-card-content>
        <mat-icon>warning</mat-icon>
        <p>Le jeune sera notifié par email du refus de son paiement.</p>
      </mat-card-content>
    </mat-card>
  </div>
</mat-dialog-content>

<mat-dialog-actions align="end">
  <button mat-button (click)="onCancel()">Annuler</button>
  <button 
    mat-raised-button 
    color="warn" 
    (click)="onConfirm()"
    [disabled]="!refusForm.valid">
    <mat-icon>cancel</mat-icon>
    Refuser
  </button>
</mat-dialog-actions>
```

### Styles communs pour les dialogues (`*.dialog.component.scss`)

```scss
.dialog-content {
  min-width: 400px;

  .info-card {
    margin: 16px 0;
    background-color: #f5f5f5;

    .info-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;

      .label {
        font-weight: 500;
        color: #666;
      }

      .value {
        font-weight: bold;

        &.montant {
          color: #4caf50;
          font-size: 18px;
        }
      }
    }
  }

  .warning-card {
    margin: 16px 0;
    background-color: #e3f2fd;
    border-left: 4px solid #2196f3;

    &.error {
      background-color: #ffebee;
      border-left-color: #f44336;

      mat-icon {
        color: #f44336;
      }
    }

    mat-card-content {
      display: flex;
      align-items: center;
      gap: 12px;

      mat-icon {
        color: #2196f3;
      }

      p {
        margin: 0;
        font-size: 14px;
      }
    }
  }

  .full-width {
    width: 100%;
  }
}
```

---

## 🔗 5. Module et Routing

### Dans `app-routing.module.ts`

```typescript
{
  path: 'admin/paiements',
  component: PaiementsComponent,
  canActivate: [AuthGuard],
  data: { role: 'ADMIN' }
}
```

### Dans `admin.module.ts`

```typescript
import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';

// Angular Material
import { MatTableModule } from '@angular/material/table';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatSortModule } from '@angular/material/sort';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDialogModule } from '@angular/material/dialog';
import { MatChipsModule } from '@angular/material/chips';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatSnackBarModule } from '@angular/material/snack-bar';

// Components
import { PaiementsComponent } from './pages/paiements/paiements.component';
import { ValidationDialogComponent } from './pages/paiements/validation-dialog/validation-dialog.component';
import { RefusDialogComponent } from './pages/paiements/refus-dialog/refus-dialog.component';

@NgModule({
  declarations: [
    PaiementsComponent,
    ValidationDialogComponent,
    RefusDialogComponent
  ],
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    // Material
    MatTableModule,
    MatPaginatorModule,
    MatSortModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatFormFieldModule,
    MatInputModule,
    MatSelectModule,
    MatDialogModule,
    MatChipsModule,
    MatProgressSpinnerModule,
    MatTooltipModule,
    MatSnackBarModule
  ]
})
export class AdminModule { }
```

---

## 📋 Checklist de Développement

- [ ] Créer les modèles TypeScript (Paiement, StatutPaiement)
- [ ] Créer le service PaiementService
- [ ] Créer le component principal PaiementsComponent
- [ ] Créer le dialogue de validation
- [ ] Créer le dialogue de refus
- [ ] Ajouter le routing
- [ ] Configurer le module avec Angular Material
- [ ] Tester la liste des paiements
- [ ] Tester la validation d'un paiement
- [ ] Tester le refus d'un paiement
- [ ] Vérifier les notifications (snackbar)
- [ ] Vérifier la réactivité (responsive design)

---

## 🎯 Fonctionnalités Bonus (Optionnelles)

1. **Export Excel** : Bouton pour exporter les paiements en Excel
2. **Statistiques** : Dashboard avec stats (total validé, en attente, refusé)
3. **Graphiques** : Chart.js pour visualiser les paiements par mois
4. **Impression** : Bouton pour imprimer la liste des paiements
5. **Détails complets** : Modal avec toutes les infos du paiement + historique
6. **Filtres avancés** : Date picker pour filtrer par période
7. **Tri personnalisé** : Sauvegarder les préférences de tri de l'utilisateur

---

**Auteur** : Interface Admin RePartir  
**Framework** : Angular + Angular Material  
**Date** : 2025-11-13


