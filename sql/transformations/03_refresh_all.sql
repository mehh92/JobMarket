-- ============================================
-- Rafraîchissement complet du pipeline
-- Exécute toutes les transformations dans l'ordre
-- ============================================

-- Étape 1 : RAW → STAGING
\echo '🔄 Étape 1/2 : Transformation RAW → STAGING...'
\i /opt/airflow/sql/transformations/01_load_staging.sql

-- Étape 2 : STAGING → ANALYTICS
\echo '🔄 Étape 2/2 : Transformation STAGING → ANALYTICS...'
\i /opt/airflow/sql/transformations/02_load_analytics.sql

-- Confirmation finale
\echo '✅ Pipeline de transformation terminé !'
\echo ''
\echo '📊 Vérification rapide :'

-- Compter les lignes dans chaque table
SELECT 
    'raw.jobs_raw' as table_name,
    COUNT(*) as row_count
FROM raw.jobs_raw
UNION ALL
SELECT 
    'staging.jobs_flattened',
    COUNT(*)
FROM staging.jobs_flattened
UNION ALL
SELECT 
    'analytics.jobs_clean',
    COUNT(*)
FROM analytics.jobs_clean;

-- Statistiques des vues
\echo ''
\echo '📈 Vues analytics disponibles :'
\echo '   • vw_salaries_by_job'
\echo '   • vw_top_companies'
\echo '   • vw_geo_distribution'
\echo '   • vw_monthly_trends'
\echo '   • vw_top_cities'

