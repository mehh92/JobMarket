# 💼 JobMarket - Analyse du Marché de l'Emploi DATA

> Projet de Data Engineering - Recensement et analyse des offres d'emploi dans le domaine de la DATA en France

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![Airflow](https://img.shields.io/badge/Apache%20Airflow-2.10-red.svg)](https://airflow.apache.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-blue.svg)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED.svg)](https://www.docker.com/)
[![API](https://img.shields.io/badge/API-Adzuna-orange.svg)](https://developer.adzuna.com/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange.svg)](https://jupyter.org/)
[![Pandas](https://img.shields.io/badge/pandas-Data%20Analysis-green.svg)](https://pandas.pydata.org/)

---

## 📋 À propos du projet

Ce projet a été développé dans le cadre d'une **formation de Data Engineer** au sein de l'organisme Data Scientist. Il a pour objectif de :

- 🔍 **Collecter** automatiquement les offres d'emploi liées aux métiers de la DATA
- 📊 **Analyser** les tendances du marché de l'emploi (salaires, compétences, localisation)
- 📈 **Visualiser** les insights pour comprendre le secteur DATA en France
- 🛠️ **Mettre en pratique** les compétences en data engineering (API, ETL, analyse)

### Données collectées

- **35 000+ offres d'emploi** récupérées via l'API Adzuna
- Recherche sur le terme **"data"** (Data Engineer, Data Analyst, Data Scientist, etc.)
- Données enrichies : salaires, localisation GPS, type de contrat, descriptions

---

## 🚀 Technologies utilisées

### Backend & Collecte
- **Python 3.8+** - Langage principal
- **Requests** - Appels API HTTP
- **Adzuna API** - Source de données d'emploi

### Orchestration & ETL
- **Apache Airflow 2.10** - Orchestrateur de workflows
- **PostgreSQL 16** - Base de données relationnelle
- **Docker & Docker Compose** - Containerisation
- **psycopg2** - Connecteur PostgreSQL

### Analyse & Visualisation
- **Pandas** - Manipulation et analyse des données
- **NumPy** - Calculs numériques
- **Matplotlib** - Visualisations statiques
- **Seaborn** - Visualisations statistiques avancées
- **Jupyter Notebook** - Environnement d'analyse interactif
- **DBeaver** - Client SQL et visualisation

### Outils
- **Git** - Gestion de versions
- **JSON** - Format de stockage temporaire

---

## 📁 Structure du projet

```
JobMarket/
│
├── README.md                       # Ce fichier
├── ARCHITECTURE.md                 # Architecture du projet
├── DECISIONS.md                    # Justifications des choix techniques
├── .gitignore                      # Exclusions Git
├── requirements.txt                # Dépendances du projet
├── docker-compose.yml             # Configuration Docker (Postgres + Airflow)
│
├── docs/                           # 📚 Documentation détaillée
│   ├── AIRFLOW_SETUP.md           # Guide Airflow
│   ├── AIRFLOW_VARIABLES.md       # Config TEST/PROD
│   ├── DATABASE_SETUP.md          # Guide PostgreSQL
│   └── DBEAVER_SETUP.md           # Guide DBeaver
│
├── dags/                           # 🔄 DAGs Airflow
│   └── jobmarket_etl_pipeline.py  # Pipeline ETL principal
│
├── src/                            # 🟢 Code source
│   ├── __init__.py                # Package Python
│   ├── config.json                # Clés API (non versionné)
│   ├── config.example.adzuna.json # Template de configuration
│   ├── scraper_adzuna.py          # Script de scraping Adzuna
│   ├── db_config.py               # Configuration PostgreSQL centralisée
│   └── db_loader.py               # Chargeur de données dans PostgreSQL
│
├── sql/                            # 🗄️ Scripts SQL
│   ├── init/                      # Scripts d'initialisation (auto-exec au 1er démarrage)
│   │   ├── 01_create_schemas.sql  # Création des schémas (raw, staging, analytics)
│   │   ├── 02_create_raw_tables.sql
│   │   ├── 03_create_staging_tables.sql
│   │   ├── 04_create_analytics_tables.sql
│   │   └── 05_create_views.sql
│   └── transformations/           # Scripts de transformation
│       ├── 01_load_staging.sql    # RAW → STAGING
│       ├── 02_load_analytics.sql  # STAGING → ANALYTICS
│       └── 03_refresh_all.sql     # Refresh complet
│
├── data/                           # 📊 Données temporaires (ignoré par Git)
│   ├── .gitkeep                   # Garde le dossier dans Git
│   └── jobs_data.json             # JSON temporaire avant PostgreSQL
│
├── notebooks/                      # 📓 Analyses Jupyter (legacy)
│   └── analysis.ipynb             # Notebook d'analyse initial
│
├── logs/                           # 📝 Logs Airflow (ignoré par Git)
│
├── tests/                          # 🧪 Tests unitaires (à venir)
│   └── .gitkeep
│
└── archive/                        # 📦 Anciennes implémentations
    ├── Adzuna API/                # Ancienne structure (obsolète)
    └── France Travail API/        # Ancienne API (obsolète)
```

---

## 🔧 Installation

### Démarrage rapide

```bash
# 1. Cloner le projet
git clone https://github.com/votre-username/JobMarket.git
cd JobMarket

# 2. Configurer les clés API Adzuna
cp src/config.example.adzuna.json src/config.json
# Éditer src/config.json avec vos clés (https://developer.adzuna.com/)

# 3. Démarrer l'infrastructure Docker
docker-compose up -d

# 4. Accéder à Airflow
# http://localhost:8080 (admin/admin)
```

### 📖 Guide d'installation complet

Pour une installation détaillée étape par étape avec toutes les explications, consultez :

👉 **[ARCHITECTURE.md - Flux d'exécution](ARCHITECTURE.md#-flux-dexécution---chronologie)**

Ce guide couvre :
- ✅ Installation initiale complète (venv, dépendances)
- ✅ Configuration détaillée de Docker
- ✅ Initialisation PostgreSQL et Airflow
- ✅ Configuration de la connexion à la base de données
- ✅ Premier lancement du pipeline
- ✅ Passage en production
- ✅ Monitoring et maintenance

---

### Analyse des données

#### 🔹 Avec DBeaver (Recommandé)

1. Connectez-vous à PostgreSQL (voir [docs/DBEAVER_SETUP.md](docs/DBEAVER_SETUP.md))


#### 🔹 Avec Jupyter Notebook (Legacy)(Plus utilisé depuis le passage à SQL)

```bash
jupyter notebook notebooks/analysis.ipynb
```

---

## 📊 Résultats et Analyses

### Statistiques clés

- **35 000+ offres** collectées dans le domaine DATA
- Couverture nationale (toute la France)
- Données incluant :
  - 💰 Fourchettes salariales (min/max)
  - 📍 Localisation précise (GPS + ville)
  - 📝 Descriptions complètes des postes
  - 🏢 Informations entreprises
  - 📄 Types de contrat (CDI, CDD, freelance)
  - 🏷️ Catégories d'emploi

### Insights disponibles

Le notebook d'analyse permet d'explorer :
- Distribution géographique des offres DATA
- Analyse des salaires par type de poste
- Compétences les plus demandées
- Tendances par type de contrat
- Entreprises qui recrutent le plus

---

## 🧠 Décisions Techniques

### Pourquoi Adzuna plutôt que France Travail ?

Le projet a initialement utilisé l'API France Travail (ex-Pôle Emploi), mais a migré vers Adzuna pour :
- ✅ **Meilleure qualité des données** (descriptions plus riches)
- ✅ **Volume supérieur** (35k vs 7k offres)
- ✅ **Couverture étendue** (agrégateur multi-sources)
- ✅ **Simplicité d'utilisation** (pas d'OAuth2 complexe)
- ✅ **Données structurées** (salaires, GPS, métadonnées)

👉 **Voir le document [DECISIONS.md](DECISIONS.md)** pour le comparatif détaillé.

---

## 🗂️ Archives

L'ancienne implémentation utilisant France Travail API est archivée dans `archive/France Travail API/`.

**Raison de l'archivage** : Qualité et volume des données insuffisants.

Voir `archive/France Travail API/README_ARCHIVE.md` pour plus de détails.

---

## 📚 Documentation

### 📋 Documentation principale

- **[ARCHITECTURE.md](ARCHITECTURE.md)** - 🏗️ Architecture complète avec schémas visuels
- **[DECISIONS.md](DECISIONS.md)** - 🧠 Justifications des choix techniques

### 📖 Guides détaillés

- **[docs/AIRFLOW_SETUP.md](docs/AIRFLOW_SETUP.md)** - 🚀 Guide complet Airflow (installation, DAG, troubleshooting)
- **[docs/AIRFLOW_VARIABLES.md](docs/AIRFLOW_VARIABLES.md)** - 🎛️ Configuration mode TEST/PRODUCTION pour le scraping
- **[docs/DATABASE_SETUP.md](docs/DATABASE_SETUP.md)** - 🗄️ Guide PostgreSQL avec Docker
- **[docs/DBEAVER_SETUP.md](docs/DBEAVER_SETUP.md)** - 🔧 Configuration DBeaver pour connexion DB

### 🔗 Ressources externes

- [src/config.example.adzuna.json](src/config.example.adzuna.json) - Template de configuration
- [Documentation API Adzuna](https://developer.adzuna.com/activedocs) - API officielle
- [Archive France Travail](archive/France%20Travail%20API/README_ARCHIVE.md) - Pourquoi archivé

---

## 🎓 Contexte de formation

Ce projet fait partie d'une formation en **Data Engineering** et démontre les compétences suivantes :

- ✅ **Collecte de données** via API REST
- ✅ **Orchestration ETL** avec Apache Airflow
- ✅ **Base de données** PostgreSQL (schemas, tables, views)
- ✅ **Containerisation** avec Docker & Docker Compose
- ✅ **Transformations SQL** (Raw → Staging → Analytics)
- ✅ **Gestion des données** (JSON, pandas, SQL)
- ✅ **Analyse exploratoire** (EDA)
- ✅ **Visualisation de données**
- ✅ **Versioning et documentation** (Git, README)
- ✅ **Bonnes pratiques** (environnements virtuels, .gitignore, sécurité des clés)

---

## 📈 Améliorations futures

- [x] ~~Automatiser la collecte quotidienne/hebdomadaire~~ ✅ (Airflow)
- [x] ~~Stocker les données dans une base PostgreSQL~~ ✅
- [ ] Créer un moteur de recherche interactif (Streamlit)
- [ ] Ajouter des tests de qualité de données (Great Expectations)
- [ ] Intégrer d'autres sources de données (technologies les plus recherchées : cloud, etl...) + extraire des descriptions les technos
- [ ] Ajouter un système d'alerting (emails Airflow) selon les préférences d'un user
- [ ] Créer des vues pour Machine Learning (prédiction de salaires)

---

## 👨‍💻 Auteur

Développé dans le cadre d'une formation en Data Engineering.

---

## 📄 Licence

Ce projet est à usage éducatif.

---

## 🙏 Remerciements

- [Adzuna](https://www.adzuna.fr/) pour l'accès à leur API
- La communauté Python pour les excellentes librairies d'analyse de données
