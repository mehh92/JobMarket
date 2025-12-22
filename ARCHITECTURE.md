# 🏗️ Architecture du Projet JobMarket

Ce document présente l'architecture complète du projet avec des schémas visuels.

---

## 📊 Vue d'ensemble - Infrastructure

```
┌─────────────────────────────────────────────────────────────────┐
│                         DOCKER COMPOSE                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │               🐘 PostgreSQL 16                         │   │
│  ├────────────────────────────────────────────────────────┤   │
│  │  Port: 5432                                            │   │
│  │  Volume: postgres_data (persistant)                    │   │
│  │                                                        │   │
│  │  ┌─────────────┐  ┌─────────────┐                    │   │
│  │  │ Base:       │  │ Base:       │                    │   │
│  │  │ airflow     │  │ jobmarket   │                    │   │
│  │  │             │  │             │                    │   │
│  │  │ Owner:      │  │ Schemas:    │                    │   │
│  │  │ airflow     │  │ • raw       │                    │   │
│  │  │             │  │ • staging   │                    │   │
│  │  │ (Métastore) │  │ • analytics │                    │   │
│  │  └─────────────┘  └─────────────┘                    │   │
│  └────────────────────────────────────────────────────────┘   │
│                              ↕                                  │
│  ┌────────────────────────────────────────────────────────┐   │
│  │            🚀 Apache Airflow 2.10                      │   │
│  ├────────────────────────────────────────────────────────┤   │
│  │  Port: 8080 (Interface Web)                            │   │
│  │  Executor: LocalExecutor                               │   │
│  │  Volume: airflow_data (persistant)                     │   │
│  │                                                        │   │
│  │  Composants:                                           │   │
│  │  • Webserver  → Interface utilisateur                 │   │
│  │  • Scheduler  → Orchestration des DAGs                │   │
│  │  • Database   → Métastore (dans PostgreSQL)           │   │
│  │                                                        │   │
│  │  Volumes montés:                                       │   │
│  │  • ./dags     → /opt/airflow/dags                     │   │
│  │  • ./src      → /opt/airflow/src                      │   │
│  │  • ./sql      → /opt/airflow/sql                      │   │
│  │  • ./data     → /opt/airflow/data                     │   │
│  │  • ./logs     → /opt/airflow/logs                     │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │              🌐 Network: jobmarket_network             │   │
│  │  (Bridge - Communication entre conteneurs)             │   │
│  └────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
          ↕
    ┌─────────┐
    │ DBeaver │  (Client SQL externe - Port 5432)
    └─────────┘
```

---

## 🔄 Flux de données - Pipeline ETL

```
┌──────────────────────────────────────────────────────────────────┐
│                    PIPELINE ETL COMPLET                          │
└──────────────────────────────────────────────────────────────────┘

1️⃣ EXTRACTION (Scraping)
   ┌─────────────┐
   │ Adzuna API  │
   └──────┬──────┘
          │ HTTP Requests
          │ (max 700 pages)
          ↓
   ┌──────────────────┐
   │ scraper_adzuna.py│ ← Python
   └──────┬───────────┘
          │ Sauvegarde
          ↓
   ┌──────────────────┐
   │ jobs_data.json   │ ← Fichier temporaire
   └──────┬───────────┘   (data/ - ignoré Git)
          │
          ↓

2️⃣ CHARGEMENT (Load to DB)
   ┌──────────────────┐
   │  db_loader.py    │ ← Python
   └──────┬───────────┘
          │ INSERT batch (1000 lignes)
          ↓
   ┌─────────────────────────────────────────┐
   │  PostgreSQL - Schema: raw               │
   ├─────────────────────────────────────────┤
   │  raw.jobs_raw                           │
   │  • id (PK)                              │
   │  • job_id (unique)                      │
   │  • data (JSONB) ← JSON complet          │
   │  • source ('adzuna')                    │
   │  • created_at / updated_at              │
   │                                         │
   │  raw.import_metadata                    │
   │  • id, search_term, total_jobs          │
   │  • scraping_date, api_source            │
   └─────────────┬───────────────────────────┘
                 │
                 ↓

3️⃣ TRANSFORMATION 1 (Staging)
   ┌──────────────────────────────────┐
   │ 01_load_staging.sql              │ ← SQL
   │ (Extraction JSON → Colonnes SQL) │
   └──────────┬───────────────────────┘
              │ INSERT/UPDATE
              ↓
   ┌─────────────────────────────────────────┐
   │  PostgreSQL - Schema: staging           │
   ├─────────────────────────────────────────┤
   │  staging.jobs_flattened                 │
   │  • job_id (PK)                          │
   │  • title, description, created          │
   │  • contract_type, contract_time         │
   │  • salary_min, salary_max               │
   │  • latitude, longitude                  │
   │  • location_display, city, region       │
   │  • company_name, category_label         │
   │  • redirect_url                         │
   │  • raw_id (FK), processed_at            │
   └─────────────┬───────────────────────────┘
                 │
                 ↓

4️⃣ TRANSFORMATION 2 (Analytics)
   ┌──────────────────────────────────┐
   │ 02_load_analytics.sql            │ ← SQL
   │ (Enrichissement + Calculs)       │
   └──────────┬───────────────────────┘
              │ INSERT/UPDATE
              ↓
   ┌─────────────────────────────────────────┐
   │  PostgreSQL - Schema: analytics         │
   ├─────────────────────────────────────────┤
   │  analytics.jobs_clean                   │
   │  • job_id (PK)                          │
   │  • [Toutes colonnes staging]            │
   │  • salary_avg, salary_avg_k (calculs)   │
   │  • is_paris, is_ile_de_france (flags)   │
   │  • is_data_scientist, is_data_analyst   │
   │  • is_data_engineer, is_alternance      │
   │  • year, month, year_month              │
   │  • description_length                   │
   └─────────────┬───────────────────────────┘
                 │
                 ↓

5️⃣ VUES ANALYTIQUES (Business Intelligence)
   ┌─────────────────────────────────────────┐
   │  Vues SQL (05_create_views.sql)         │
   ├─────────────────────────────────────────┤
   │  📊 vw_salaries_by_job                  │
   │     → Salaires moyens par type de poste │
   │                                         │
   │  🏢 vw_top_companies                    │
   │     → Entreprises qui recrutent le +    │
   │                                         │
   │  🗺️ vw_geo_distribution                 │
   │     → Répartition géographique          │
   │                                         │
   │  📈 vw_monthly_trends                   │
   │     → Tendances mensuelles              │
   │                                         │
   │  🏙️ vw_top_cities                       │
   │     → Top villes par nombre d'offres    │
   └─────────────┬───────────────────────────┘
                 │
                 ↓
          ┌──────────────┐
          │   DBeaver    │  Requêtes SQL / Visualisations
          │   Metabase   │  Dashboards interactifs
          │   Superset   │  Analyses avancées
          │   Power BI   │  Rapports business
          └──────────────┘
```

---

## 🎯 Architecture du DAG Airflow

```
┌────────────────────────────────────────────────────────────────┐
│           DAG: jobmarket_etl_pipeline                          │
│           Schedule: Manuel (ou @daily en production)           │
└────────────────────────────────────────────────────────────────┘

     ┌─────────────────┐
     │  start_pipeline │  (DummyOperator)
     └────────┬────────┘
              │
              ↓
     ┌──────────────────────────────────────────┐
     │  scrape_adzuna                           │  PythonOperator
     │  • Appelle scraper_adzuna.py             │  Durée: 1-30 min
     │  • Récupère données depuis Adzuna API    │  (selon mode)
     │  • Sauvegarde dans jobs_data.json        │
     │  • XCom: filepath, nb_jobs               │
     └────────┬─────────────────────────────────┘
              │
              ↓
     ┌──────────────────────────────────────────┐
     │  load_to_postgres                        │  PythonOperator
     │  • Appelle db_loader.py                  │  Durée: 10-30s
     │  • Charge JSON → raw.jobs_raw            │
     │  • Insert métadonnées                    │
     │  • XCom: import_id, nb_jobs_inserted     │
     └────────┬─────────────────────────────────┘
              │
              ↓
     ┌──────────────────────────────────────────┐
     │  transform_to_staging                    │  PostgresOperator
     │  • Exécute 01_load_staging.sql           │  Durée: 5-10s
     │  • RAW → STAGING (aplatissement JSON)    │
     │  • Extraction colonnes                   │
     └────────┬─────────────────────────────────┘
              │
              ↓
     ┌──────────────────────────────────────────┐
     │  transform_to_analytics                  │  PostgresOperator
     │  • Exécute 02_load_analytics.sql         │  Durée: 5-10s
     │  • STAGING → ANALYTICS (enrichissement)  │
     │  • Calculs + Flags                       │
     └────────┬─────────────────────────────────┘
              │
              ↓
     ┌──────────────────────────────────────────┐
     │  verify_pipeline                         │  PythonOperator
     │  • Compte lignes dans chaque table       │  Durée: 2-5s
     │  • Affiche statistiques                  │
     │  • Vérifie intégrité                     │
     └────────┬─────────────────────────────────┘
              │
              ↓
     ┌─────────────────┐
     │  end_pipeline   │  (DummyOperator)
     └─────────────────┘

Variables Airflow (configuration):
  • scraping_mode: "test" (5 pages) ou "production" (700 pages)
  • search_term: "data"
  • test_max_pages: 5
  • max_pages: 700
  • delay: 0.2
```

---

## 📁 Structure des fichiers du projet

```
JobMarket/
│
├── 📄 Configuration & Documentation
│   ├── README.md                    # Vue d'ensemble
│   ├── ARCHITECTURE.md              # Ce fichier (architecture)
│   ├── DECISIONS.md                 # Choix techniques
│   ├── .gitignore                  # Exclusions Git
│   ├── requirements.txt            # Dépendances Python
│   └── docker-compose.yml          # Infrastructure Docker
│
├── 📚 docs/                        # Documentation détaillée
│   ├── AIRFLOW_SETUP.md            # Guide Airflow
│   ├── AIRFLOW_VARIABLES.md        # Config modes TEST/PROD
│   ├── DATABASE_SETUP.md           # Guide PostgreSQL
│   └── DBEAVER_SETUP.md            # Guide DBeaver
│
├── 🔄 dags/                        # DAGs Airflow
│   └── jobmarket_etl_pipeline.py   # Pipeline ETL principal
│
├── 🐍 src/                         # Code source Python
│   ├── __init__.py
│   ├── config.json                 # Clés API (non versionné)
│   ├── config.example.adzuna.json  # Template config
│   ├── scraper_adzuna.py           # Scraper Adzuna API
│   ├── db_config.py                # Config PostgreSQL
│   ├── db_loader.py                # Chargeur PostgreSQL
│   └── README.md                   # Doc du code source
│
├── 🗄️ sql/                         # Scripts SQL
│   ├── init/                       # Initialisation (auto-exec)
│   │   ├── 00_create_airflow_db.sql    # Base Airflow
│   │   ├── 01_create_schemas.sql       # raw, staging, analytics
│   │   ├── 02_create_raw_tables.sql    # Tables RAW
│   │   ├── 03_create_staging_tables.sql # Tables STAGING
│   │   ├── 04_create_analytics_tables.sql # Tables ANALYTICS
│   │   └── 05_create_views.sql         # Vues analytiques
│   │
│   └── transformations/            # Transformations ETL
│       ├── 01_load_staging.sql     # RAW → STAGING
│       ├── 02_load_analytics.sql   # STAGING → ANALYTICS
│       └── 03_refresh_all.sql      # Refresh complet
│
├── 📊 data/                        # Données (ignoré Git)
│   ├── .gitkeep
│   └── jobs_data.json              # JSON temporaire
│
├── 📓 notebooks/                   # Analyses Jupyter (legacy)
│   └── analysis.ipynb              # Notebook d'analyse
│
├── 📝 logs/                        # Logs Airflow (ignoré Git)
│
├── 🧪 tests/                       # Tests unitaires (à venir)
│   └── .gitkeep
│
└── 📦 archive/                     # Anciennes versions
    ├── Adzuna API/                 # Ancienne structure
    └── France Travail API/         # Ancienne API
```

---

## 🗄️ Schémas PostgreSQL - Structure détaillée

```
Database: jobmarket
│
├── Schema: raw (Données brutes)
│   │
│   ├── Table: jobs_raw
│   │   ├── id (PK) → INTEGER
│   │   ├── job_id → VARCHAR(50) UNIQUE
│   │   ├── data → JSONB ★ (JSON complet de l'API)
│   │   ├── source → VARCHAR(50) ('adzuna')
│   │   ├── created_at → TIMESTAMP
│   │   └── updated_at → TIMESTAMP
│   │
│   └── Table: import_metadata
│       ├── id (PK) → SERIAL
│       ├── search_term → VARCHAR(100)
│       ├── total_jobs → INTEGER
│       ├── scraping_date → TIMESTAMP
│       └── api_source → VARCHAR(50)
│
├── Schema: staging (Données aplaties)
│   │
│   └── Table: jobs_flattened
│       ├── job_id (PK) → VARCHAR(50)
│       ├── title → TEXT
│       ├── description → TEXT
│       ├── created → TIMESTAMP
│       ├── contract_type → VARCHAR(50)
│       ├── contract_time → VARCHAR(50)
│       ├── salary_min → NUMERIC(10,2)
│       ├── salary_max → NUMERIC(10,2)
│       ├── salary_is_predicted → VARCHAR(10)
│       ├── latitude → NUMERIC(10,6)
│       ├── longitude → NUMERIC(10,6)
│       ├── location_display → VARCHAR(255)
│       ├── country → VARCHAR(100)
│       ├── region → VARCHAR(100)
│       ├── department → VARCHAR(100)
│       ├── city → VARCHAR(100)
│       ├── company_name → VARCHAR(255)
│       ├── category_label → VARCHAR(255)
│       ├── category_tag → VARCHAR(100)
│       ├── redirect_url → TEXT
│       ├── raw_id (FK) → INTEGER
│       └── processed_at → TIMESTAMP
│
└── Schema: analytics (Données enrichies)
    │
    ├── Table: jobs_clean
    │   ├── job_id (PK) → VARCHAR(50)
    │   ├── [Toutes colonnes de staging]
    │   ├── salary_avg → NUMERIC(10,2) ★ Calculé
    │   ├── salary_min_k → NUMERIC(10,2) ★ /1000
    │   ├── salary_max_k → NUMERIC(10,2) ★ /1000
    │   ├── salary_avg_k → NUMERIC(10,2) ★ /1000
    │   ├── is_paris → BOOLEAN ★ Flag
    │   ├── is_ile_de_france → BOOLEAN ★ Flag
    │   ├── is_data_scientist → BOOLEAN ★ Flag
    │   ├── is_data_analyst → BOOLEAN ★ Flag
    │   ├── is_data_engineer → BOOLEAN ★ Flag
    │   ├── is_alternance → BOOLEAN ★ Flag
    │   ├── year → INTEGER ★ Extrait
    │   ├── month → INTEGER ★ Extrait
    │   ├── year_month → VARCHAR(7) ★ 'YYYY-MM'
    │   ├── description_length → INTEGER ★ Calculé
    │   ├── staging_id → VARCHAR(50)
    │   └── created_at → TIMESTAMP
    │
    └── Vues (Views)
        ├── vw_salaries_by_job       → Salaires moyens
        ├── vw_top_companies         → Top entreprises
        ├── vw_geo_distribution      → Distribution géo
        ├── vw_monthly_trends        → Tendances mensuelles
        └── vw_top_cities            → Top villes
```

---

## 🔐 Sécurité & Gestion des secrets

```
┌─────────────────────────────────────────────────────────────┐
│                   GESTION DES SECRETS                        │
└─────────────────────────────────────────────────────────────┘

Fichiers sensibles (NON versionnés dans Git):
  ├── src/config.json              ← Clés API Adzuna
  ├── data/jobs_data.json          ← Données scrapées
  ├── logs/*                       ← Logs Airflow
  └── .pgdata/                     ← Données PostgreSQL

Fichiers versionnés (templates):
  └── src/config.example.adzuna.json  ← Template pour config.json

Variables d'environnement (docker-compose.yml):
  PostgreSQL:
    • POSTGRES_USER: jobmarket_user
    • POSTGRES_PASSWORD: jobmarket_pass
    • POSTGRES_DB: jobmarket
  
  Airflow:
    • AIRFLOW__DATABASE__SQL_ALCHEMY_CONN: postgresql://airflow:airflow@...
    • AIRFLOW__CORE__FERNET_KEY: (clé de chiffrement)
    • AIRFLOW__WEBSERVER__SECRET_KEY: (clé de session)
    • JOBMARKET_DB_* (connexion à la DB métier)
```

---

## 🚀 Flux d'exécution - Chronologie

```
DÉMARRAGE DU PROJET
═══════════════════════════════════════════════════════════════

1. Installation initiale
   ─────────────────────
   $ git clone <repo>
   $ cd JobMarket
   $ python -m venv venv
   $ venv\Scripts\activate
   $ pip install -r requirements.txt
   $ cp src/config.example.adzuna.json src/config.json
   $ # Éditer src/config.json avec vos clés API

2. Démarrage Docker
   ────────────────
   $ docker-compose up -d
   
   → PostgreSQL démarre
     ├─ Exécute sql/init/* dans l'ordre
     ├─ Crée base "airflow" + user "airflow"
     ├─ Crée base "jobmarket"
     ├─ Crée schemas: raw, staging, analytics
     ├─ Crée tables + index
     └─ Crée vues analytiques
   
   → Airflow démarre (dépend de PostgreSQL)
     ├─ Init DB dans base "airflow"
     ├─ Crée user admin/admin
     ├─ Démarre Webserver (port 8080)
     └─ Démarre Scheduler

3. Configuration Airflow (une seule fois)
   ──────────────────────────────────────
   http://localhost:8080 (admin/admin)
   
   → Admin → Connections → Add
     Connection ID: jobmarket_postgres
     Type: Postgres
     Host: postgres
     Schema: jobmarket
     Login: jobmarket_user
     Password: jobmarket_pass
     Port: 5432

4. Exécution du pipeline (mode TEST par défaut)
   ────────────────────────────────────────────
   → Activer le DAG "jobmarket_etl_pipeline"
   → Cliquer "Trigger DAG"
   
   Étapes (mode TEST - 5 pages):
   [00:00] ► start_pipeline
   [00:01] ► scrape_adzuna (1-2 min)
           └─ Scrape 5 pages (~100 offres)
           └─ Sauvegarde data/jobs_data.json
   [02:00] ► load_to_postgres (10-30s)
           └─ Charge JSON dans raw.jobs_raw
   [02:30] ► transform_to_staging (5-10s)
           └─ Aplatit JSON en colonnes SQL
   [02:40] ► transform_to_analytics (5-10s)
           └─ Enrichit avec calculs et flags
   [02:50] ► verify_pipeline (2-5s)
           └─ Vérifie + affiche statistiques
   [02:55] ► end_pipeline
   [02:55] ✅ PIPELINE TERMINÉ

5. Analyse des résultats
   ─────────────────────
   → DBeaver: Connexion à localhost:5432
   → Requêtes SQL sur analytics.*
   → Utilisation des vues pré-calculées

PASSAGE EN PRODUCTION
═══════════════════════════════════════════════════════════════

1. Passer en mode PRODUCTION
   ─────────────────────────
   Airflow → Admin → Variables → Add
   Key: scraping_mode
   Val: production

2. Planification automatique (optionnel)
   ────────────────────────────────────
   Modifier dags/jobmarket_etl_pipeline.py:
   schedule_interval='0 6 * * *'  # Tous les jours à 6h
   
   $ docker-compose restart airflow

3. Monitoring
   ──────────
   → Airflow UI: Vérifier les runs
   → DBeaver: Vérifier la qualité des données
   → Logs: docker-compose logs -f airflow
```

---

## 📊 Volumétrie & Performances

```
MODE TEST (5 pages)
───────────────────────────────────────
Données:           ~100 offres
Durée totale:      2-3 minutes
  ├─ Scraping:     1-2 min
  ├─ Load:         10-30s
  ├─ Transform:    10-20s
  └─ Verify:       2-5s

Taille fichier:    ~200 KB (JSON)
Taille DB:         ~50 KB (PostgreSQL)


MODE PRODUCTION (700 pages)
───────────────────────────────────────
Données:           ~14 000 offres
Durée totale:      30-35 minutes
  ├─ Scraping:     25-30 min
  ├─ Load:         30-60s
  ├─ Transform:    10-30s
  └─ Verify:       5-10s

Taille fichier:    ~30 MB (JSON)
Taille DB:         ~15 MB (PostgreSQL)
  ├─ raw:          ~10 MB (JSONB)
  ├─ staging:      ~3 MB (colonnes)
  └─ analytics:    ~2 MB (enrichi)
```

---

## 🎯 Points clés de l'architecture

### ✅ Avantages

1. **Modularité** : Chaque composant a un rôle précis
2. **Scalabilité** : Docker facilite le déploiement
3. **Maintenabilité** : Code organisé, bien documenté
4. **Flexibilité** : Mode TEST/PROD configurables
5. **Traçabilité** : Logs Airflow + métadonnées DB
6. **Résilience** : Retry automatique, gestion erreurs
7. **Performance** : Index SQL, batch insert

### 📈 Évolutions futures possibles

1. **Airflow distribué** : CeleryExecutor pour parallélisation
2. **Cache Redis** : Améliorer performances Airflow
3. **Data quality** : Great Expectations pour validation
4. **CI/CD** : GitHub Actions pour tests automatiques
5. **Monitoring** : Prometheus + Grafana
6. **BI Tool** : Metabase ou Superset pour dashboards
7. **ML Pipeline** : Prédiction salaires, classification

---

## 📚 Liens vers la documentation

### Documentation principale
- [README.md](README.md) - Vue d'ensemble du projet
- [DECISIONS.md](DECISIONS.md) - Décisions techniques

### Guides détaillés (docs/)
- [docs/AIRFLOW_SETUP.md](docs/AIRFLOW_SETUP.md) - Configuration Airflow
- [docs/AIRFLOW_VARIABLES.md](docs/AIRFLOW_VARIABLES.md) - Modes TEST/PRODUCTION
- [docs/DATABASE_SETUP.md](docs/DATABASE_SETUP.md) - Configuration PostgreSQL
- [docs/DBEAVER_SETUP.md](docs/DBEAVER_SETUP.md) - Configuration DBeaver

---

**📝 Note** : Ce document est mis à jour régulièrement. Version: 1.0 (Décembre 2025)

