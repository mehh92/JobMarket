# Adzuna API - Scraper d'offres d'emploi

## Structure du dossier

```
Adzuna API/
├── README.md                    # Ce fichier
├── scraper/
│   ├── adzuna_scraper.py       # Script principal
│   └── config.json             # Configuration des clés API
└── data/                       # Données récupérées
    └── jobs_*.json             # Fichiers JSON des offres
```

## Fichiers principaux

### 1. `scraper/adzuna_scraper.py`
- Script Python qui récupère les offres d'emploi via l'API Adzuna
- Parcourt automatiquement toutes les pages disponibles
- Sauvegarde les données en JSON avec métadonnées

### 2. `scraper/config.json`
- Contient vos clés API Adzuna (app_id et app_key)
- Format :
  ```json
  {
    "adzuna": {
      "app_id": "votre_app_id",
      "app_key": "votre_app_key"
    }
  }
  ```

## Utilisation

1. **Configurer vos clés API dans `scraper/config.json`**

2. **Lancer le script :**
   ```bash
   cd scraper
   python adzuna_scraper.py
   ```

3. **Les données sont sauvegardées dans :**
   ```
   data/
   ```

## Paramètres configurables

Dans le script `adzuna_scraper.py`, vous pouvez modifier :
- `search_term` : Terme de recherche (ex: "data", "informatique")
- `max_pages` : Nombre de pages max (None = toutes)
- `delay` : Délai entre requêtes (secondes)

## Format de sortie

```json
{
  "metadata": {
    "search_term": "data",
    "total_jobs": 500,
    "scraping_date": "2024-01-15T14:30:00",
    "api_source": "Adzuna"
  },
  "jobs": [...]
}
```

## 📊 Analyse des données

### Analyse automatique avec Python
```bash
# Installer les dépendances d'analyse
pip install pandas matplotlib seaborn plotly

# Lancer l'analyse automatique
python data_analysis.py
```

Le script `data_analysis.py` va :
- ✅ Transformer le JSON en DataFrame pandas
- ✅ Nettoyer et enrichir les données  
- ✅ Créer des statistiques détaillées
- ✅ Générer des visualisations
- ✅ Exporter un CSV nettoyé

### Fichiers d'analyse disponibles
- `data_analysis.py` - Script d'analyse automatique
- `requirements_analysis.txt` - Dépendances pour l'analyse
- `data/jobs_cleaned_*.csv` - Données nettoyées exportées
- `data/analyse_offres_emploi.png` - Graphiques générés 