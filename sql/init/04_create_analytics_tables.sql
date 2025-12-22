-- ============================================
-- Script d'initialisation : Tables ANALYTICS
-- ============================================

-- Table analytics finale avec enrichissements
CREATE TABLE IF NOT EXISTS analytics.jobs_clean (
    -- Identifiants
    job_id VARCHAR(50) PRIMARY KEY,
    
    -- Informations principales
    title TEXT,
    description TEXT,
    created TIMESTAMP,
    
    -- Contrat
    contract_type VARCHAR(50),
    contract_time VARCHAR(50),
    
    -- Salaires (avec calculs)
    salary_min NUMERIC(10, 2),
    salary_max NUMERIC(10, 2),
    salary_avg NUMERIC(10, 2),
    salary_min_k NUMERIC(10, 2),
    salary_max_k NUMERIC(10, 2),
    salary_avg_k NUMERIC(10, 2),
    
    -- Localisation
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    location_display VARCHAR(255),
    country VARCHAR(100),
    region VARCHAR(100),
    department VARCHAR(100),
    city VARCHAR(100),
    
    -- Flags géographiques
    is_paris BOOLEAN,
    is_ile_de_france BOOLEAN,
    
    -- Entreprise et catégorie
    company_name VARCHAR(255),
    category_label VARCHAR(255),
    category_tag VARCHAR(100),
    
    -- Flags métiers
    is_data_scientist BOOLEAN,
    is_data_analyst BOOLEAN,
    is_data_engineer BOOLEAN,
    is_alternance BOOLEAN,
    
    -- Dimensions temporelles
    year INTEGER,
    month INTEGER,
    year_month VARCHAR(7),
    
    -- Autres
    description_length INTEGER,
    redirect_url TEXT,
    
    -- Métadonnées
    staging_id VARCHAR(50) REFERENCES staging.jobs_flattened(job_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour analyses
CREATE INDEX IF NOT EXISTS idx_analytics_company ON analytics.jobs_clean(company_name);
CREATE INDEX IF NOT EXISTS idx_analytics_year_month ON analytics.jobs_clean(year, month);
CREATE INDEX IF NOT EXISTS idx_analytics_salary ON analytics.jobs_clean(salary_avg_k) WHERE salary_avg_k IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_analytics_paris ON analytics.jobs_clean(is_paris);
CREATE INDEX IF NOT EXISTS idx_analytics_ds ON analytics.jobs_clean(is_data_scientist);
CREATE INDEX IF NOT EXISTS idx_analytics_da ON analytics.jobs_clean(is_data_analyst);
CREATE INDEX IF NOT EXISTS idx_analytics_de ON analytics.jobs_clean(is_data_engineer);

-- Commentaires
COMMENT ON TABLE analytics.jobs_clean IS 'Table finale enrichie pour analyses BI';

-- Confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Tables ANALYTICS créées avec succès';
END $$;


