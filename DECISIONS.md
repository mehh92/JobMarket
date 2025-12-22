# 📋 Décisions Techniques du Projet

## Choix de l'API : Adzuna vs France Travail

### Contexte

Dans le cadre de ce projet de recensement des offres d'emploi dans le domaine de la DATA, deux APIs ont été évaluées :
- **France Travail API** (ex-Pôle Emploi)
- **Adzuna API**

### Décision finale : Migration vers Adzuna ✅

**Date de décision :** Juin 2025

---

## Comparaison des deux APIs

### 🔴 France Travail API - Points faibles

#### 1. **Qualité des données insuffisante**
- Informations limitées dans les offres d'emploi (uniquement les emplois non cadre)
- Descriptions souvent peu détaillées

#### 2. **Périmètre limité**
- Uniquement les offres publiées sur France Travail
- Couverture partielle du marché réel de l'emploi
- Biais vers certains secteurs et types d'employeurs 

#### 3. **Complexité de l'authentification**
- Processus OAuth2 avec tokens
- Nécessite une inscription et validation manuelle
- Gestion des scopes et des credentials plus complexe

#### 4. **Structure des données**
- Basée sur les codes ROME (classification française)
- Moins flexible pour les recherches par mots-clés
- Structure spécifique au contexte français

**Code utilisé :**
```python
# Authentification OAuth2 requise
scope = "api_offresdemploiv2 o2dsoffre"
auth_url = "https://entreprise.pole-emploi.fr/connexion/oauth2/access_token?realm=/partenaire"
# Recherche par codes ROME uniquement
codes_rome = ["M1802","M1803","M1804","M1805","M1806","M1807","M1810", "M1811"]
```

---

### 🟢 Adzuna API - Avantages

#### 1. **Qualité et richesse des données**
- Descriptions détaillées des offres
- Informations salariales (min/max)
- Métadonnées complètes (localisation GPS, catégories, type de contrat)
- Données structurées et exploitables pour l'analyse

#### 2. **Couverture étendue du marché**
- Agrégateur multi-sources (sites d'emploi, entreprises, etc.)
- Couverture plus large du marché réel
- Meilleure représentativité du secteur DATA

#### 3. **Simplicité d'utilisation**
- Authentification simple avec app_id et app_key
- API RESTful claire et bien documentée
- Pas de processus de validation complexe

#### 4. **Flexibilité des recherches**
- Recherche par mots-clés libres (`what=data`)
- Pagination simple et efficace
- Nombreux filtres disponibles

#### 5. **Documentation et communauté**
- Documentation complète et à jour
- Nombreux exemples de code
- Active Docs interactifs

#### 6. **Performance**
- Réponses rapides et fiables
- 50 résultats par page
- Gestion automatique de la pagination

**Code utilisé :**
```python
# Authentification simple
params = {
    'app_id': self.app_id,
    'app_key': self.app_key,
    'results_per_page': 50,
    'what': 'data'  # Recherche flexible par mot-clé
}
```

---

## Résultats comparatifs

| Critère | France Travail | Adzuna |
|---------|---------------|--------|
| **Nombre d'offres collectées** | ~7000 (8 codes ROME) | 35 000+ |
| **Qualité des données** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Facilité d'implémentation** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Couverture du marché** | ⭐⭐ | ⭐⭐⭐⭐ |
| **Richesse des informations** | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Documentation** | ⭐⭐⭐ | ⭐⭐⭐ |

---

## Impact sur le projet

### Avantages de la migration

1. **Volume de données** : Passage de ~7k à 35k offres
2. **Analyses plus riches** : Données salariales, géolocalisation précise
3. **Code plus simple** : Réduction de la complexité d'authentification
4. **Maintenance facilitée** : API stable et bien documentée
5. **Résultats plus représentatifs** : Meilleure vision du marché DATA

### Actions réalisées

- ✅ Développement du scraper Adzuna (`adzuna_scraper.py`)
- ✅ Collecte de 35 000 offres
- ✅ Archivage du code France Travail dans `archive/`

---

## Conclusion

Le choix d'**Adzuna** s'est révélé être la meilleure décision pour ce projet de data engineering :
- Données de meilleure qualité et plus volumineuses
- Implémentation plus rapide et maintenable
- Meilleure base pour les analyses statistiques et visualisations

L'ancienne implémentation France Travail est conservée dans le dossier `archive/` à titre de référence historique.

---

**Dernière mise à jour :** Décembre 2025

