# 🎛️ Configuration des Variables Airflow

Ce document explique comment configurer le pipeline JobMarket via les Variables Airflow.

---

## 🧪 Mode TEST vs 🚀 Mode PRODUCTION

Le DAG supporte deux modes de fonctionnement :

| Mode | Pages scrapées | Offres | Durée | Usage |
|------|----------------|--------|-------|-------|
| **TEST** | 5 pages | ~100 | 1-2 min | Tests, développement |
| **PRODUCTION** | 700 pages | ~14 000 | 25-30 min | Collecte complète |

**Par défaut** : Le DAG démarre en **mode TEST** pour éviter les longs scraping pendant le développement.

---

## 🔧 Configuration via l'interface Airflow

### Méthode 1 : Via l'interface web (Recommandé)

1. **Accédez à Airflow** : http://localhost:8080
2. Connectez-vous (admin/admin)
3. Allez dans **Admin → Variables**
4. Cliquez sur **"+"** (Add a new record)

### Variables disponibles

#### 1. Mode de scraping (obligatoire pour passer en PRODUCTION)

```
Key: scraping_mode
Val: test          (par défaut - 5 pages)
Val: production    (complet - 700 pages)
```

#### 2. Terme de recherche (optionnel)

```
Key: search_term
Val: data          (par défaut)
```

#### 3. Nombre de pages en mode TEST (optionnel)

```
Key: test_max_pages
Val: 5             (par défaut)
```

Vous pouvez augmenter à 10 ou 20 pages pour un test intermédiaire.

#### 4. Nombre de pages en mode PRODUCTION (optionnel)

```
Key: max_pages
Val: 700           (par défaut)
```

#### 5. Délai entre requêtes (optionnel)

```
Key: delay
Val: 0.2           (par défaut, en secondes)
```

---

## 📋 Exemples de configuration

### Exemple 1 : Mode TEST (par défaut)

**Aucune variable à créer !** Le DAG fonctionne en mode TEST par défaut.

**Résultat :**
- 5 pages scrapées
- ~100 offres
- Durée : 1-2 minutes

## 🎯 Guide de démarrage rapide

### Pour vos premiers tests (recommandé)

1. **Ne créez AUCUNE variable** → Mode TEST activé automatiquement
2. Lancez le DAG
3. Vérifiez que tout fonctionne (1-2 minutes)

### Pour passer en production

1. Allez dans **Admin → Variables**
2. Ajoutez : `scraping_mode` = `production`
3. Lancez le DAG
4. Attendez ~30 minutes

### Pour revenir en mode test

1. Allez dans **Admin → Variables**
2. Modifiez : `scraping_mode` = `test`
3. Ou supprimez la variable complètement

---

## 🔍 Vérification de la configuration

### Dans les logs Airflow

Après avoir lancé le DAG, consultez les logs de la tâche `scrape_adzuna` :

```
🔍 ÉTAPE 1: SCRAPING ADZUNA
============================================================
🧪 MODE TEST activé (scraping limité)
📊 Configuration du scraping:
   • Mode: TEST
   • Terme de recherche: 'data'
   • Nombre de pages: 5
   • Délai entre requêtes: 0.2s
🔄 Scraping en cours (terme: 'data', max_pages: 5)...
```


## 🎬 Workflow recommandé

### Phase de développement

1. **Jour 1-2** : Mode TEST (5 pages) pour vérifier que tout fonctionne
2. **Jour 3** : Test intermédiaire (50 pages) pour valider les transformations SQL
3. **Jour 4** : Production réduite (200 pages) pour tester la charge
4. **Jour 5+** : Production complète (700 pages) pour la collecte réelle

### En production

- Planifier le DAG en mode PRODUCTION quotidiennement (à 6h du matin par exemple)
- Utiliser le mode TEST uniquement pour déboguer un problème

---

## 📊 Estimation du temps de scraping

| Pages | Offres | Durée estimée |
|-------|--------|---------------|
| 5 | ~100 | 1-2 min |
| 10 | ~200 | 2-3 min |
| 50 | ~1 000 | 5-7 min |
| 100 | ~2 000 | 10-12 min |
| 200 | ~4 000 | 15-18 min |
| 500 | ~10 000 | 20-25 min |
| 700 | ~14 000 | 25-30 min |

*Note : Le délai par défaut est de 0.2s entre chaque requête pour respecter les limites de l'API.*

---

## ⚠️ Important

### Limites de l'API Adzuna

- **Gratuit** : 250 requêtes/jour
- **Premium** : Limites plus élevées

Si vous approchez de la limite :
1. Réduisez `max_pages`
2. Augmentez `delay` (ex: 0.5s)
3. Lancez le scraping moins fréquemment

### Variables par défaut

Si une variable n'est pas définie dans Airflow, le DAG utilisera ces valeurs par défaut :

```python
scraping_mode = "test"
search_term = "data"
test_max_pages = 5
max_pages = 700
delay = 0.2
```

---

## 🔗 Voir aussi

- [AIRFLOW_SETUP.md](AIRFLOW_SETUP.md) - Configuration générale d'Airflow
- [README.md](../README.md) - Vue d'ensemble du projet
- [dags/jobmarket_etl_pipeline.py](../dags/jobmarket_etl_pipeline.py) - Code du DAG

---

**💡 Astuce** : Pendant le développement, gardez le mode TEST activé par défaut. Vous pourrez toujours passer en PRODUCTION plus tard en ajoutant simplement une variable !

