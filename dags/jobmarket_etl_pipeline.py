"""
DAG Airflow : Pipeline ETL JobMarket

Ce DAG orchestre le pipeline complet :
1. Scraping des offres d'emploi depuis Adzuna
2. Chargement dans PostgreSQL (RAW)
3. Transformation vers STAGING
4. Transformation vers ANALYTICS
5. Vérification finale

Auteur: JobMarket Project
"""

from datetime import datetime, timedelta
from pathlib import Path
import json
import sys

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.dummy import DummyOperator

# Ajouter le dossier src au path pour imports
sys.path.insert(0, '/opt/airflow/src')

# Configuration par défaut du DAG
default_args = {
    'owner': 'jobmarket',
    'depends_on_past': False,
    'start_date': datetime(2025, 1, 1),
    'email': ['admin@jobmarket.local'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 2,
    'retry_delay': timedelta(minutes=5),
}


def scrape_adzuna_jobs(**context):
    """
    Tâche 1: Scrape les offres d'emploi depuis l'API Adzuna
    """
    from scraper_adzuna import AdzunaJobScraper, load_config
    
    print("=" * 60)
    print("🔍 ÉTAPE 1: SCRAPING ADZUNA")
    print("=" * 60)
    
    # Charger la configuration
    config = load_config()
    if not config:
        raise ValueError("❌ Fichier config.json introuvable ou invalide")
    
    adzuna_config = config.get('adzuna', {})
    app_id = adzuna_config.get('app_id')
    app_key = adzuna_config.get('app_key')
    
    if not app_id or not app_key:
        raise ValueError("❌ Clés API Adzuna manquantes dans config.json")
    
    # Paramètres de scraping
    search_term = "data"
    max_pages = 700  # ou None pour tout
    delay = 0.2
    
    # Créer le scraper et récupérer les données
    print(f"🔄 Scraping en cours (terme: '{search_term}', max_pages: {max_pages})...")
    scraper = AdzunaJobScraper(app_id, app_key)
    
    all_jobs = scraper.scrape_all_jobs(
        search_term=search_term,
        max_pages=max_pages,
        delay=delay
    )
    
    if not all_jobs:
        raise ValueError("❌ Aucune offre récupérée")
    
    # Sauvegarder dans data/
    filepath = scraper.save_to_json(all_jobs, search_term=search_term)
    
    print(f"\n✅ Scraping terminé avec succès!")
    print(f"   📊 Nombre d'offres: {len(all_jobs)}")
    print(f"   💾 Fichier: {filepath}")
    
    # Passer le chemin du fichier à la tâche suivante
    context['task_instance'].xcom_push(key='json_filepath', value=str(filepath))
    context['task_instance'].xcom_push(key='nb_jobs', value=len(all_jobs))
    
    return str(filepath)


def load_to_postgres(**context):
    """
    Tâche 2: Charge le JSON dans PostgreSQL (raw schema)
    """
    from db_loader import JobMarketLoader
    
    print("=" * 60)
    print("📥 ÉTAPE 2: CHARGEMENT DANS POSTGRESQL")
    print("=" * 60)
    
    # Récupérer le chemin du fichier JSON de la tâche précédente
    ti = context['task_instance']
    json_filepath = ti.xcom_pull(task_ids='scrape_adzuna', key='json_filepath')
    
    if not json_filepath:
        raise ValueError("❌ Chemin du fichier JSON introuvable")
    
    json_path = Path(json_filepath)
    if not json_path.exists():
        raise FileNotFoundError(f"❌ Fichier introuvable: {json_path}")
    
    print(f"📂 Fichier JSON: {json_path}")
    
    # Charger les données
    loader = JobMarketLoader()
    result = loader.load_from_json(json_path)
    
    if not result['success']:
        raise ValueError("❌ Échec du chargement")
    
    print(f"\n✅ Chargement terminé avec succès!")
    print(f"   📊 Import ID: {result['import_id']}")
    print(f"   📋 Offres insérées: {result['nb_jobs_inserted']}")
    
    # Passer les stats à la tâche suivante
    ti.xcom_push(key='import_id', value=result['import_id'])
    ti.xcom_push(key='nb_jobs_inserted', value=result['nb_jobs_inserted'])
    
    return result['nb_jobs_inserted']


def verify_pipeline(**context):
    """
    Tâche finale: Vérifie que le pipeline s'est bien exécuté
    """
    print("=" * 60)
    print("✅ VÉRIFICATION FINALE")
    print("=" * 60)
    
    ti = context['task_instance']
    
    # Récupérer les stats des tâches précédentes
    nb_jobs_scraped = ti.xcom_pull(task_ids='scrape_adzuna', key='nb_jobs')
    nb_jobs_inserted = ti.xcom_pull(task_ids='load_to_postgres', key='nb_jobs_inserted')
    import_id = ti.xcom_pull(task_ids='load_to_postgres', key='import_id')
    
    # Vérifier les tables via PostgreSQL
    hook = PostgresHook(postgres_conn_id='jobmarket_postgres')
    
    # Compter les lignes dans chaque table
    counts = {
        'raw': hook.get_first("SELECT COUNT(*) FROM raw.jobs_raw")[0],
        'staging': hook.get_first("SELECT COUNT(*) FROM staging.jobs_flattened")[0],
        'analytics': hook.get_first("SELECT COUNT(*) FROM analytics.jobs_clean")[0]
    }
    
    print("\n📊 STATISTIQUES DU PIPELINE:")
    print(f"   🔍 Offres scrapées: {nb_jobs_scraped}")
    print(f"   📥 Offres insérées (RAW): {nb_jobs_inserted}")
    print(f"   🗃️  Import ID: {import_id}")
    print("\n📋 TABLES POSTGRESQL:")
    print(f"   • raw.jobs_raw: {counts['raw']} lignes")
    print(f"   • staging.jobs_flattened: {counts['staging']} lignes")
    print(f"   • analytics.jobs_clean: {counts['analytics']} lignes")
    
    # Vérifications
    if counts['raw'] == 0:
        raise ValueError("❌ Table raw.jobs_raw vide!")
    if counts['staging'] == 0:
        raise ValueError("❌ Table staging.jobs_flattened vide!")
    if counts['analytics'] == 0:
        raise ValueError("❌ Table analytics.jobs_clean vide!")
    
    print("\n✅ PIPELINE TERMINÉ AVEC SUCCÈS! 🎉")
    print("=" * 60)
    
    return {
        'nb_jobs_scraped': nb_jobs_scraped,
        'nb_jobs_inserted': nb_jobs_inserted,
        'import_id': import_id,
        'counts': counts
    }


# Définition du DAG
with DAG(
    'jobmarket_etl_pipeline',
    default_args=default_args,
    description='Pipeline ETL complet pour JobMarket (Adzuna → PostgreSQL)',
    schedule_interval=None,  # Manuel pour l'instant (mettre '@daily' pour quotidien)
    catchup=False,
    tags=['etl', 'jobmarket', 'adzuna', 'postgresql'],
) as dag:
    
    # Tâche de démarrage (optionnelle, pour visualisation)
    start = DummyOperator(
        task_id='start_pipeline',
    )
    
    # Tâche 1: Scraping Adzuna
    scrape_task = PythonOperator(
        task_id='scrape_adzuna',
        python_callable=scrape_adzuna_jobs,
        provide_context=True,
    )
    
    # Tâche 2: Chargement RAW
    load_task = PythonOperator(
        task_id='load_to_postgres',
        python_callable=load_to_postgres,
        provide_context=True,
    )
    
    # Tâche 3: Transformation STAGING
    transform_staging_task = PostgresOperator(
        task_id='transform_to_staging',
        postgres_conn_id='jobmarket_postgres',
        sql='transformations/01_load_staging.sql',
    )
    
    # Tâche 4: Transformation ANALYTICS
    transform_analytics_task = PostgresOperator(
        task_id='transform_to_analytics',
        postgres_conn_id='jobmarket_postgres',
        sql='transformations/02_load_analytics.sql',
    )
    
    # Tâche 5: Vérification finale
    verify_task = PythonOperator(
        task_id='verify_pipeline',
        python_callable=verify_pipeline,
        provide_context=True,
    )
    
    # Tâche de fin (optionnelle, pour visualisation)
    end = DummyOperator(
        task_id='end_pipeline',
    )
    
    # Définir l'ordre d'exécution (DAG)
    start >> scrape_task >> load_task >> transform_staging_task >> transform_analytics_task >> verify_task >> end

