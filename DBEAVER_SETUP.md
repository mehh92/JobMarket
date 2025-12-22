# 🦫 Configuration DBeaver pour JobMarket

Guide pour se connecter à PostgreSQL avec DBeaver.

---

## 📥 Installation DBeaver

### **Option 1 : Téléchargement direct (recommandé)**
1. Aller sur : https://dbeaver.io/download/
2. Télécharger **DBeaver Community Edition** (gratuit)
3. Installer (suivre les étapes par défaut)

### **Option 2 : Avec winget (si disponible)**
```powershell
winget install dbeaver.dbeaver
```

---

## 🔗 Connexion à PostgreSQL

### **Étape 1 : Créer une nouvelle connexion**

1. Ouvrir DBeaver
2. Cliquer sur **Database** → **New Database Connection** (ou Ctrl+Shift+N)
3. Sélectionner **PostgreSQL**
4. Cliquer sur **Next**

### **Étape 2 : Configurer la connexion**

Entrer les informations suivantes :

| Paramètre | Valeur |
|-----------|--------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Database** | `jobmarket` |
| **Username** | `jobmarket_user` |
| **Password** | `jobmarket_pass` |
| **Show all databases** | ❌ (décocher) |

### **Étape 3 : Tester et sauvegarder**

1. Cliquer sur **Test Connection**
   - Si première fois : DBeaver va télécharger le driver PostgreSQL (automatique)
   - Résultat attendu : ✅ **Connected**

2. Cliquer sur **Finish**

---

## 📊 Navigation dans la base

Une fois connecté, vous verrez :

```
jobmarket
├── 📂 Databases
│   └── jobmarket
│       ├── 📂 Schemas
│       │   ├── raw            → Données JSON brutes
│       │   │   ├── Tables
│       │   │   │   ├── jobs_raw
│       │   │   │   └── import_metadata
│       │   ├── staging        → Données aplaties
│       │   │   └── Tables
│       │   │       └── jobs_flattened
│       │   └── analytics      → Données finales + vues
│       │       ├── Tables
│       │       │   └── jobs_clean
│       │       └── Views
│       │           ├── vw_geo_distribution
│       │           ├── vw_monthly_trends
│       │           ├── vw_salaries_by_job
│       │           ├── vw_top_cities
│       │           └── vw_top_companies
```


## ✅ Checklist de validation

- [ ] DBeaver installé
- [ ] Connexion à `jobmarket` créée
- [ ] Test de connexion réussi

---

## 🎯 Avantages de DBeaver

✅ **Gratuit et open source**  
✅ **Supporte PostgreSQL nativement**  
✅ **Visualisations intégrées** (graphiques)  
✅ **Export facile** (CSV, Excel, JSON, etc.)  
✅ **Auto-complétion SQL** intelligente  
✅ **Gestion multi-bases** (PostgreSQL, MySQL, etc.)  
✅ **Diagrammes ER** automatiques  
✅ **Stable sur Windows** (contrairement à pgAdmin)  

---

