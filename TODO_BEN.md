# 📝 TODO - Ben

## 🔴 Urgent

- [ ] **Augmenter le nombre de pages API** - Actuellement ~5000 offres (beaucoup de doublons après page 100)
  - Analyser le point de saturation de l'API
  - Ajuster `max_pages` dans Airflow Variables
  
- [ ] **Nettoyer les données**
  - Supprimer les doublons dans le scraper
  - Vérifier l'API y'a des doublons chelou
  - Filtrer les offres non pertinentes
  - Harmoniser les formats (salaires, dates)
  - Améliorer les title_normalized

- [ ] **Extraction des technos depuis descriptions**
  - Regex/NLP pour extraire : Python, SQL, Docker, AWS, etc.
  - Créer une table `analytics.job_technologies`
  - Ajouter vue pour top technos par métier

## 🟡 À faire

- [ ] Tester différents termes de recherche (data engineer, data scientist, data analyst)
- [ ] Ajouter des tests unitaires (pytest)

## 🟢 Idées futures

- [ ] Scraping multi-sources (Indeed, LinkedIn)
- [ ] ML salaire

---

**Dernière mise à jour :** 22/12/2025

