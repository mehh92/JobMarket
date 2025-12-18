# ⚠️ Dossier Archivé - Ancienne structure Adzuna API

## Statut : OBSOLÈTE (structure remplacée)

Ce dossier contient l'ancienne structure du projet avant la refactorisation de décembre 2025.

## Pourquoi archivé ?

La structure du projet a été **réorganisée selon les bonnes pratiques Git et Python** :

### Problèmes de l'ancienne structure :
- ❌ Nom de dossier avec espaces (`"Adzuna API/"`)
- ❌ Fichiers de données (1.87 MB) versionnés dans Git
- ❌ Chemins codés en dur dans le code
- ❌ Multiples fichiers `requirements.txt` fragmentés
- ❌ Pas de structure de package Python

### Nouvelle structure (décembre 2025) :
- ✅ Structure propre : `src/`, `data/`, `notebooks/`, `tests/`
- ✅ Données exclues de Git (`.gitignore` mis à jour)
- ✅ Chemins relatifs dynamiques avec `pathlib`
- ✅ Requirements unifiés (`requirements.txt` + `requirements-dev.txt`)
- ✅ Package Python avec `__init__.py`
- ✅ Configuration centralisée (`config.json` à la racine)

## Contenu de cette archive

```
Adzuna API/
├── README.md                  # Ancienne documentation
├── scraper/
│   ├── adzuna_scraper.py     # Ancien scraper (remplacé par src/scraper.py)
│   ├── config.json           # Ancienne config (déplacée à la racine)
│   ├── requirements.txt      # Ancien requirements (unifié)
│   └── readme.md
├── data/
│   └── jobs_data.json        # Anciennes données (déplacées vers data/)
└── analysis/
    ├── jobs_data.ipynb       # Ancien notebook (déplacé vers notebooks/)
    └── requirements.txt      # Ancien requirements (unifié)
```

## Migration effectuée

### Fichiers déplacés/refactorisés :
- `scraper/adzuna_scraper.py` → `src/scraper.py` (refactorisé)
- `scraper/config.json` → `config.json` (racine)
- `data/jobs_data.json` → `data/jobs_data.json` (racine)
- `analysis/jobs_data.ipynb` → `notebooks/analysis.ipynb`

### Nouveaux fichiers créés :
- `src/__init__.py` - Package Python
- `config.example.json` - Template de config
- `requirements.txt` - Dépendances unifiées
- `requirements-dev.txt` - Dépendances dev
- `src/README.md` - Documentation du code source

## Utilisation actuelle

🚫 **Ne pas utiliser ce code pour le projet.**  
✅ **Voir la documentation à la racine du projet pour la nouvelle structure.**

## Date d'archivage

Décembre 2025

---

*Ce dossier est conservé à titre d'archive pour l'historique du projet.*

