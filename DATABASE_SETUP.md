# 🗄️ Setup PostgreSQL avec Docker

Guide complet pour démarrer PostgreSQL en local avec Docker.

---

## 📋 Prérequis

1. **Docker Desktop** installé et lancé
   - Télécharger : https://www.docker.com/products/docker-desktop
   - Vérifier : `docker --version`

2. **Python** avec psycopg2
   ```bash
   pip install -r requirements.txt
   ```

---

## 🚀 Démarrage rapide (3 étapes)

### **Étape 1 : Démarrer PostgreSQL**

```bash
# Dans le dossier racine du projet
cd C:\Users\xxx\Documents\JobMarket

# Démarrer les conteneurs Docker
docker-compose up -d
```

**Ce qui se passe :**
- 🐘 PostgreSQL démarre sur le port `5432`
- 🌐 pgAdmin démarre sur `http://localhost:5050`
- 📂 Les scripts SQL dans `sql/init/` sont exécutés automatiquement
- ✅ Les schémas, tables et vues sont créés

### **Étape 2 : Vérifier que tout fonctionne**

```bash
# Voir les logs
docker-compose logs postgres

# Vérifier que le conteneur tourne
docker ps
```

Vous devriez voir :
```
CONTAINER ID   IMAGE                  STATUS        PORTS
xxxxx          postgres:16-alpine     Up 10 seconds 0.0.0.0:5432->5432/tcp
```

## 🔧 Configuration

### **Credentials par défaut**

| Paramètre | Valeur |
|-----------|--------|
| **Host** | localhost |
| **Port** | 5432 |
| **Database** | jobmarket |
| **User** | jobmarket_user |
| **Password** | jobmarket_pass |

⚠️ **Note** : Changez ces credentials en production !

## 📊 Structure de la base de données

### **Schémas**

```
jobmarket (database)
├── raw          → Données brutes (JSON)
├── staging      → Données aplaties
└── analytics    → Données enrichies + vues
```

### **Tables principales**

| Schéma | Table | Description | Lignes |
|--------|-------|-------------|--------|
| `raw` | `jobs_raw` | JSON brut des offres | À remplir |
| `raw` | `import_metadata` | Métadonnées des imports | À remplir |
| `staging` | `jobs_flattened` | Données aplaties | À remplir |
| `analytics` | `jobs_clean` | Données finales enrichies | À remplir |

### **Vues pour analyses**

| Vue | Description |
|-----|-------------|
| `vw_salaries_by_job` | Statistiques salariales par métier |
| `vw_top_companies` | Top 50 entreprises qui recrutent |
| `vw_geo_distribution` | Répartition Paris / IdF / Province |
| `vw_monthly_trends` | Évolution mensuelle du marché |
| `vw_top_cities` | Top 30 villes |

---

## 🛠️ Commandes utiles

### **Gestion des conteneurs**

```bash
# Démarrer
docker-compose up -d

# Arrêter
docker-compose down

# Voir les logs
docker-compose logs -f postgres

# Redémarrer
docker-compose restart

# Supprimer tout (ATTENTION : supprime les données)
docker-compose down -v
```


## 📁 Structure des fichiers

```
JobMarket/
├── docker-compose.yml              # Configuration Docker
├── DATABASE_SETUP.md              # Ce fichier
│
├── sql/
│   └── init/                      # Scripts exécutés au 1er démarrage
│       ├── 01_create_schemas.sql
│       ├── 02_create_raw_tables.sql
│       ├── 03_create_staging_tables.sql
│       ├── 04_create_analytics_tables.sql
│       └── 05_create_views.sql
│
└── src/
    └── test_db_connection.py      # Script de test
```

---

## ✅ Checklist de validation

- [ ] Docker Desktop est lancé
- [ ] `docker-compose up -d` fonctionne sans erreur

---


**PostgreSQL est maintenant prêt ! 🎉**


