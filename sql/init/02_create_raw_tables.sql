-- ============================================
-- Script d'initialisation : Tables RAW
-- ============================================

-- Table pour stocker les données JSON brutes
CREATE TABLE IF NOT EXISTS raw.jobs_raw (
    id SERIAL PRIMARY KEY,
    job_id VARCHAR(50) UNIQUE NOT NULL,
    data JSONB NOT NULL,
    source VARCHAR(50) DEFAULT 'adzuna',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances des requêtes JSONB
CREATE INDEX IF NOT EXISTS idx_jobs_raw_data_gin ON raw.jobs_raw USING GIN (data);
CREATE INDEX IF NOT EXISTS idx_jobs_raw_job_id ON raw.jobs_raw(job_id);
CREATE INDEX IF NOT EXISTS idx_jobs_raw_created_at ON raw.jobs_raw(created_at);

-- Table pour stocker les métadonnées des imports
CREATE TABLE IF NOT EXISTS raw.import_metadata (
    id SERIAL PRIMARY KEY,
    search_term VARCHAR(100),
    total_jobs INTEGER,
    scraping_date TIMESTAMP,
    api_source VARCHAR(50),
    import_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Commentaires pour documentation
COMMENT ON TABLE raw.jobs_raw IS 'Stockage des offres d''emploi au format JSON brut';
COMMENT ON COLUMN raw.jobs_raw.job_id IS 'ID unique de l''offre (provenant de l''API)';
COMMENT ON COLUMN raw.jobs_raw.data IS 'Données JSON complètes de l''offre';
COMMENT ON TABLE raw.import_metadata IS 'Métadonnées des imports de données';

-- Confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Tables RAW créées avec succès';
END $$;


