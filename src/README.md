# Source Code - Adzuna Job Scraper

Ce dossier contient le code source du projet.

## Fichiers

### `scraper_adzuna.py`
Script principal de collecte des offres d'emploi via l'API Adzuna.

**Utilisation :**
```bash
# Depuis la racine du projet
python src/scraper_adzuna.py

# Ou en tant que module
python -m src.scraper_adzuna
```

**Fonctionnalités :**
- Classe `AdzunaJobScraper` pour la collecte des offres
- Pagination automatique
- Gestion des erreurs
- Sauvegarde JSON avec métadonnées
- Chemins relatifs dynamiques (utilise `pathlib`)

**Améliorations par rapport à l'ancienne version :**
- ✅ Chemins relatifs au lieu de chemins codés en dur
- ✅ Utilisation de `pathlib.Path` pour la portabilité
- ✅ Meilleure gestion de la configuration
- ✅ Type hints avec `Optional`
- ✅ Messages d'erreur plus clairs
- ✅ Code plus maintenable

### `__init__.py`
Transforme le dossier en package Python importable.

### `config.example.adzuna.json`
Template de configuration pour les clés API Adzuna.

### `config.json` (non versionné)
Fichier de configuration avec vos clés API personnelles.

## Configuration

Le script cherche le fichier `config.json` dans le dossier `src/`.

Format attendu :
```json
{
  "adzuna": {
    "app_id": "your_app_id",
    "app_key": "your_app_key"
  }
}
```

**Créer votre configuration :**
```bash
# Copier le template
cp src/config.example.adzuna.json src/config.json
# Éditer avec vos vraies clés
```

## Dépendances

Voir `requirements.txt` à la racine du projet :
- `requests>=2.28.0` - Pour les appels API

## Tests

Les tests seront ajoutés dans le dossier `tests/` (à venir).

