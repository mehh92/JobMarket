-- ============================================
-- Script d'initialisation : Vues pour analyses
-- ============================================

-- Vue : Statistiques salariales par type de poste
CREATE OR REPLACE VIEW analytics.vw_salaries_by_job AS
SELECT 
    CASE 
        WHEN is_data_scientist THEN 'Data Scientist'
        WHEN is_data_analyst THEN 'Data Analyst'
        WHEN is_data_engineer THEN 'Data Engineer'
        ELSE 'Autres'
    END AS job_type,
    COUNT(*) AS nb_offres,
    COUNT(*) FILTER (WHERE salary_avg_k IS NOT NULL) AS nb_offres_avec_salaire,
    ROUND(AVG(salary_avg_k)::NUMERIC, 1) AS salaire_moyen,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_avg_k)::NUMERIC, 1) AS salaire_median,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_avg_k)::NUMERIC, 1) AS q1,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_avg_k)::NUMERIC, 1) AS q3
FROM analytics.jobs_clean
GROUP BY job_type
ORDER BY nb_offres DESC;

-- Vue : Top entreprises qui recrutent
CREATE OR REPLACE VIEW analytics.vw_top_companies AS
SELECT 
    company_name,
    COUNT(*) AS nb_offres,
    COUNT(*) FILTER (WHERE salary_avg_k IS NOT NULL) AS nb_offres_avec_salaire,
    ROUND(AVG(salary_avg_k)::NUMERIC, 1) AS salaire_moyen,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_avg_k)::NUMERIC, 1) AS salaire_median
FROM analytics.jobs_clean
WHERE company_name IS NOT NULL
GROUP BY company_name
ORDER BY nb_offres DESC
LIMIT 50;

-- Vue : Répartition géographique
CREATE OR REPLACE VIEW analytics.vw_geo_distribution AS
SELECT 
    CASE 
        WHEN is_paris THEN 'Paris'
        WHEN is_ile_de_france THEN 'Île-de-France (hors Paris)'
        ELSE 'Province'
    END AS zone,
    COUNT(*) AS nb_offres,
    ROUND((COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ())::NUMERIC, 1) AS pourcentage,
    ROUND(AVG(salary_avg_k)::NUMERIC, 1) AS salaire_moyen,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary_avg_k)::NUMERIC, 1) AS salaire_median
FROM analytics.jobs_clean
GROUP BY zone
ORDER BY nb_offres DESC;

-- Vue : Évolution temporelle
CREATE OR REPLACE VIEW analytics.vw_monthly_trends AS
SELECT 
    year,
    month,
    year_month,
    COUNT(*) AS nb_offres,
    COUNT(*) FILTER (WHERE is_data_scientist) AS nb_data_scientist,
    COUNT(*) FILTER (WHERE is_data_analyst) AS nb_data_analyst,
    COUNT(*) FILTER (WHERE is_data_engineer) AS nb_data_engineer,
    ROUND(AVG(salary_avg_k)::NUMERIC, 1) AS salaire_moyen
FROM analytics.jobs_clean
GROUP BY year, month, year_month
ORDER BY year, month;

-- Vue : Top villes
CREATE OR REPLACE VIEW analytics.vw_top_cities AS
SELECT 
    location_display,
    COUNT(*) AS nb_offres,
    ROUND(AVG(salary_avg_k)::NUMERIC, 1) AS salaire_moyen
FROM analytics.jobs_clean
WHERE location_display IS NOT NULL
GROUP BY location_display
ORDER BY nb_offres DESC
LIMIT 30;

-- Commentaires
COMMENT ON VIEW analytics.vw_salaries_by_job IS 'Statistiques salariales par type de poste';
COMMENT ON VIEW analytics.vw_top_companies IS 'Top 50 entreprises qui recrutent';
COMMENT ON VIEW analytics.vw_geo_distribution IS 'Répartition géographique des offres';
COMMENT ON VIEW analytics.vw_monthly_trends IS 'Évolution mensuelle du marché';
COMMENT ON VIEW analytics.vw_top_cities IS 'Top 30 villes/localisations';

-- Confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Vues ANALYTICS créées avec succès';
    RAISE NOTICE 'ℹ️  Vues disponibles : vw_salaries_by_job, vw_top_companies, vw_geo_distribution, vw_monthly_trends, vw_top_cities';
END $$;


