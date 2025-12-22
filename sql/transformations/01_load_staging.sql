-- ============================================
-- Transformation RAW → STAGING
-- Aplatit les données JSON en colonnes SQL
-- ============================================

-- Vider staging (pour refresh complet)
TRUNCATE TABLE staging.jobs_flattened CASCADE;

-- Insérer les données aplaties depuis raw.jobs_raw
INSERT INTO staging.jobs_flattened (
    job_id,
    title,
    description,
    created,
    contract_type,
    contract_time,
    salary_min,
    salary_max,
    salary_is_predicted,
    latitude,
    longitude,
    location_display,
    country,
    region,
    department,
    city,
    company_name,
    category_label,
    category_tag,
    redirect_url,
    raw_id,
    processed_at
)
SELECT 
    -- Identifiant
    (data->>'id')::VARCHAR AS job_id,
    
    -- Informations principales
    data->>'title' AS title,
    data->>'description' AS description,
    (data->>'created')::TIMESTAMP AS created,
    
    -- Contrat
    data->>'contract_type' AS contract_type,
    data->>'contract_time' AS contract_time,
    
    -- Salaires
    (data->>'salary_min')::NUMERIC AS salary_min,
    (data->>'salary_max')::NUMERIC AS salary_max,
    data->>'salary_is_predicted' AS salary_is_predicted,
    
    -- Localisation
    (data->>'latitude')::NUMERIC AS latitude,
    (data->>'longitude')::NUMERIC AS longitude,
    data->'location'->>'display_name' AS location_display,
    data->'location'->'area'->>0 AS country,
    data->'location'->'area'->>1 AS region,
    data->'location'->'area'->>2 AS department,
    CASE 
        WHEN jsonb_array_length(data->'location'->'area') > 0 
        THEN data->'location'->'area'->>-1  -- Dernier élément
        ELSE NULL 
    END AS city,
    
    -- Entreprise et catégorie
    data->'company'->>'display_name' AS company_name,
    data->'category'->>'label' AS category_label,
    data->'category'->>'tag' AS category_tag,
    
    -- URL
    data->>'redirect_url' AS redirect_url,
    
    -- Métadonnées
    id AS raw_id,
    CURRENT_TIMESTAMP AS processed_at
FROM raw.jobs_raw
ON CONFLICT (job_id) 
DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    created = EXCLUDED.created,
    contract_type = EXCLUDED.contract_type,
    contract_time = EXCLUDED.contract_time,
    salary_min = EXCLUDED.salary_min,
    salary_max = EXCLUDED.salary_max,
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    location_display = EXCLUDED.location_display,
    country = EXCLUDED.country,
    region = EXCLUDED.region,
    department = EXCLUDED.department,
    city = EXCLUDED.city,
    company_name = EXCLUDED.company_name,
    category_label = EXCLUDED.category_label,
    category_tag = EXCLUDED.category_tag,
    redirect_url = EXCLUDED.redirect_url,
    processed_at = CURRENT_TIMESTAMP;


