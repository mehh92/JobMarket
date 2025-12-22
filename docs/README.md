# 📚 Documentation du Projet JobMarket

Ce dossier contient les guides détaillés pour l'installation, la configuration et l'utilisation du projet.

---

## 📖 Guides disponibles

### 🚀 [AIRFLOW_SETUP.md](AIRFLOW_SETUP.md)
**Guide complet Apache Airflow**

Apprenez à :
- Installer et démarrer Airflow avec Docker
- Configurer la connexion PostgreSQL
- Utiliser le DAG `jobmarket_etl_pipeline`
- Résoudre les problèmes courants
- Planifier l'exécution automatique

---

### 🎛️ [AIRFLOW_VARIABLES.md](AIRFLOW_VARIABLES.md)
**Configuration des modes TEST/PRODUCTION**

Configurez le pipeline pour :
- Mode TEST : 5 pages (~1-2 min)
- Mode PRODUCTION : 700 pages (~30 min)
- Tests intermédiaires personnalisés
- Variables Airflow avancées

---

### 🗄️ [DATABASE_SETUP.md](DATABASE_SETUP.md)
**Guide PostgreSQL avec Docker**

Configurez PostgreSQL pour :
- Démarrer la base de données
- Comprendre la structure (raw, staging, analytics)
- Vérifier les schémas et tables
- Résoudre les problèmes de connexion

---

### 🔧 [DBEAVER_SETUP.md](DBEAVER_SETUP.md)
**Configuration DBeaver**

Connectez-vous à PostgreSQL avec DBeaver :
- Installation de DBeaver
- Configuration de la connexion
- Exécution de requêtes SQL
- Exploration des vues analytiques

---

## 🗺️ Parcours recommandé

### Pour démarrer le projet
```
1. DATABASE_SETUP.md    → Démarrer PostgreSQL
2. AIRFLOW_SETUP.md     → Configurer Airflow
3. AIRFLOW_VARIABLES.md → Comprendre les modes TEST/PROD
4. DBEAVER_SETUP.md     → Analyser les données
```

### Pour la production
```
1. AIRFLOW_VARIABLES.md → Passer en mode PRODUCTION
2. AIRFLOW_SETUP.md     → Planifier l'exécution automatique
```

---

## 🔗 Documentation principale

Retour à la documentation principale :

- [README.md](../README.md) - Vue d'ensemble du projet
- [ARCHITECTURE.md](../ARCHITECTURE.md) - Architecture technique détaillée
- [DECISIONS.md](../DECISIONS.md) - Décisions techniques et comparaisons

---

## 💡 Besoin d'aide ?

1. **Consultez les guides** dans l'ordre recommandé
2. **Vérifiez les logs** : `docker-compose logs -f airflow`
3. **Relisez ARCHITECTURE.md** pour comprendre le flux complet
4. **Testez en mode TEST** avant de passer en production

---

**📝 Note** : Cette documentation est maintenue à jour avec le projet. Si vous trouvez une erreur ou une information manquante, n'hésitez pas à contribuer !

