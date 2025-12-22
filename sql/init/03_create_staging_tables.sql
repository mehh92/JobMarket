-- ============================================
-- Script d'initialisation : Tables STAGING
-- ============================================

-- Table staging avec données aplaties
CREATE TABLE IF NOT EXISTS staging.jobs_flattened (
    -- Identifiants
    job_id VARCHAR(50) PRIMARY KEY,
    
    -- Informations principales
    title TEXT,
    description TEXT,
    created TIMESTAMP,
    
    -- Contrat
    contract_type VARCHAR(50),
    contract_time VARCHAR(50),
    
    -- Salaires
    salary_min NUMERIC(10, 2),
    salary_max NUMERIC(10, 2),
    salary_is_predicted VARCHAR(10),
    
    -- Localisation
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    location_display VARCHAR(255),
    country VARCHAR(100),
    region VARCHAR(100),
    department VARCHAR(100),
    city VARCHAR(100),
    
    -- Entreprise et catégorie
    company_name VARCHAR(255),
    category_label VARCHAR(255),
    category_tag VARCHAR(100),
    
    -- Autres
    redirect_url TEXT,
    
    -- Métadonnées
    raw_id INTEGER REFERENCES raw.jobs_raw(id),
    processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_staging_company ON staging.jobs_flattened(company_name);
CREATE INDEX IF NOT EXISTS idx_staging_location ON staging.jobs_flattened(location_display);
CREATE INDEX IF NOT EXISTS idx_staging_created ON staging.jobs_flattened(created);
CREATE INDEX IF NOT EXISTS idx_staging_region ON staging.jobs_flattened(region);

-- Commentaires
COMMENT ON TABLE staging.jobs_flattened IS 'Données aplaties extraites du JSON brut';

-- Confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Tables STAGING créées avec succès';
END $$;


