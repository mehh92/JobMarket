# 💼 JobMarket - Analyse du Marché de l'Emploi DATA

> Projet de Data Engineering - Recensement et analyse des offres d'emploi dans le domaine de la DATA en France

[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg)](https://www.python.org/)
[![API](https://img.shields.io/badge/API-Adzuna-orange.svg)](https://developer.adzuna.com/)
[![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-orange.svg)](https://jupyter.org/)
[![Pandas](https://img.shields.io/badge/pandas-Data%20Analysis-green.svg)](https://pandas.pydata.org/)

---

## 📋 À propos du projet

Ce projet a été développé dans le cadre d'une **formation de Data Engineer**. Il a pour objectif de :

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

### Analyse & Visualisation
- **Pandas** - Manipulation et analyse des données
- **NumPy** - Calculs numériques
- **Matplotlib** - Visualisations statiques
- **Seaborn** - Visualisations statistiques avancées
- **Jupyter Notebook** - Environnement d'analyse interactif

### Outils
- **Git** - Gestion de versions
- **JSON** - Format de stockage des données

---

## 📁 Structure du projet

```
JobMarket/
│
├── README.md                       # Ce fichier
├── DECISIONS.md                    # Justifications des choix techniques
├── .gitignore                      # Exclusions Git
│
├── Adzuna API/                     # 🟢 Module principal (actif)
│   ├── README.md                   # Documentation détaillée du module
│   │
│   ├── scraper/                    # Module de collecte
│   │   ├── adzuna_scraper.py      # Script de scraping
│   │   ├── config.json            # Clés API (non versionné)
│   │   ├── requirements.txt       # Dépendances scraper
│   │   └── readme.md              # Lien documentation API
│   │
│   ├── data/                       # Données collectées
│   │   └── jobs_data.json         # 35k offres (36k+ lignes JSON)
│   │
│   └── analysis/                   # Module d'analyse
│       ├── jobs_data.ipynb        # Notebook d'analyse principal
│       └── requirements.txt       # Dépendances analyse
│
└── archive/                        # 📦 Anciennes implémentations
    └── France Travail API/        # Ancienne API (obsolète)
        └── README_ARCHIVE.md      # Raisons de l'archivage
```

---

## 🔧 Installation

### 1. Cloner le repository

```bash
git clone https://github.com/votre-username/JobMarket.git
cd JobMarket
```

### 2. Créer un environnement virtuel

```bash
# Créer l'environnement
python -m venv venv

# Activer l'environnement
# Sur Windows :
venv\Scripts\activate
# Sur Linux/Mac :
source venv/bin/activate
```

### 3. Installer les dépendances

```bash
# Pour le scraper uniquement
pip install -r "Adzuna API/scraper/requirements.txt"

# Pour l'analyse complète
pip install -r "Adzuna API/analysis/requirements.txt"
```

### 4. Configurer les clés API

1. Créez un compte sur [Adzuna Developer](https://developer.adzuna.com/)
2. Récupérez votre `app_id` et `app_key`
3. Créez le fichier `Adzuna API/scraper/config.json` :

```json
{
  "adzuna": {
    "app_id": "votre_app_id",
    "app_key": "votre_app_key"
  }
}
```

⚠️ **Note** : Le fichier `config.json` est ignoré par Git pour protéger vos clés API.

---

## 💻 Utilisation

### Collecte des données

```bash
cd "Adzuna API/scraper"
python adzuna_scraper.py
```

**Paramètres configurables** (dans le script) :
- `search_term` : Terme de recherche (défaut: `"data"`)
- `max_pages` : Nombre max de pages (défaut: `700`, `None` = toutes)
- `delay` : Délai entre requêtes en secondes (défaut: `0.2`)

**Sortie** :
- Fichier JSON dans `Adzuna API/data/jobs_data.json`
- Métadonnées : terme de recherche, date, nombre total

### Analyse des données

```bash
cd "Adzuna API/analysis"
jupyter notebook jobs_data.ipynb
```

Le notebook permet de :
- ✅ Charger et explorer les données JSON
- ✅ Transformer en DataFrame pandas
- ✅ Nettoyer et enrichir les données
- ✅ Créer des visualisations (salaires, localisation, contrats)
- ✅ Extraire des insights métier

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

## 📚 Documentation complémentaire

- [README Adzuna API](Adzuna%20API/README.md) - Documentation détaillée du module de collecte
- [DECISIONS.md](DECISIONS.md) - Justifications des choix techniques
- [Documentation API Adzuna](https://developer.adzuna.com/activedocs) - API officielle

---

## 🎓 Contexte de formation

Ce projet fait partie d'une formation en **Data Engineering** et démontre les compétences suivantes :

- ✅ **Collecte de données** via API REST
- ✅ **Gestion des données** (JSON, pandas)
- ✅ **Nettoyage et transformation** (ETL)
- ✅ **Analyse exploratoire** (EDA)
- ✅ **Visualisation de données**
- ✅ **Versioning et documentation** (Git, README)
- ✅ **Bonnes pratiques** (environnements virtuels, .gitignore, sécurité des clés)

---

## 📈 Améliorations futures

- [ ] Automatiser la collecte quotidienne/hebdomadaire
- [ ] Stocker les données dans une base PostgreSQL
- [ ] Créer un dashboard interactif (Streamlit/Dash)
- [ ] Ajouter des analyses de tendances temporelles
- [ ] Intégrer d'autres sources de données d'emploi

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
