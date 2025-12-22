-- ============================================
-- Transformation STAGING → ANALYTICS
-- Enrichit les données avec calculs et flags
-- ============================================

-- Vider analytics (pour refresh complet)
TRUNCATE TABLE analytics.jobs_clean CASCADE;

-- Insérer les données enrichies depuis staging
INSERT INTO analytics.jobs_clean (
    job_id,
    title,
    description,
    created,
    contract_type,
    contract_time,
    salary_min,
    salary_max,
    salary_avg,
    salary_min_k,
    salary_max_k,
    salary_avg_k,
    latitude,
    longitude,
    location_display,
    country,
    region,
    department,
    city,
    is_paris,
    is_ile_de_france,
    company_name,
    category_label,
    category_tag,
    is_data_scientist,
    is_data_analyst,
    is_data_engineer,
    is_alternance,
    year,
    month,
    year_month,
    description_length,
    redirect_url,
    staging_id,
    created_at
)
SELECT 
    -- Identifiants
    job_id,
    
    -- Informations principales
    title,
    description,
    created,
    
    -- Contrat
    contract_type,
    contract_time,
    
    -- Salaires (avec calculs)
    salary_min,
    salary_max,
    (salary_min + salary_max) / 2 AS salary_avg,
    salary_min / 1000 AS salary_min_k,
    salary_max / 1000 AS salary_max_k,
    (salary_min + salary_max) / 2000 AS salary_avg_k,
    
    -- Localisation
    latitude,
    longitude,
    location_display,
    country,
    region,
    department,
    city,
    
    -- Flags géographiques
    (location_display ILIKE '%Paris%') AS is_paris,
    (region ILIKE '%Ile-de-France%' OR region ILIKE '%Île-de-France%') AS is_ile_de_france,
    
    -- Entreprise et catégorie
    company_name,
    category_label,
    category_tag,
    
    -- Flags métiers (détection dans le titre)
    (title ILIKE '%Data Scientist%') AS is_data_scientist,
    (title ILIKE '%Data Analyst%') AS is_data_analyst,
    (title ILIKE '%Data Engineer%') AS is_data_engineer,
    (title ILIKE '%alternance%' OR title ILIKE '%apprentissage%') AS is_alternance,
    
    -- Dimensions temporelles
    EXTRACT(YEAR FROM created)::INTEGER AS year,
    EXTRACT(MONTH FROM created)::INTEGER AS month,
    TO_CHAR(created, 'YYYY-MM') AS year_month,
    
    -- Autres
    LENGTH(description) AS description_length,
    redirect_url,
    
    -- Métadonnées
    job_id AS staging_id,
    CURRENT_TIMESTAMP AS created_at
FROM staging.jobs_flattened
ON CONFLICT (job_id)
DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    created = EXCLUDED.created,
    salary_min = EXCLUDED.salary_min,
    salary_max = EXCLUDED.salary_max,
    salary_avg = EXCLUDED.salary_avg,
    salary_min_k = EXCLUDED.salary_min_k,
    salary_max_k = EXCLUDED.salary_max_k,
    salary_avg_k = EXCLUDED.salary_avg_k,
    location_display = EXCLUDED.location_display,
    is_paris = EXCLUDED.is_paris,
    is_ile_de_france = EXCLUDED.is_ile_de_france,
    company_name = EXCLUDED.company_name,
    is_data_scientist = EXCLUDED.is_data_scientist,
    is_data_analyst = EXCLUDED.is_data_analyst,
    is_data_engineer = EXCLUDED.is_data_engineer,
    year = EXCLUDED.year,
    month = EXCLUDED.month,
    year_month = EXCLUDED.year_month;

