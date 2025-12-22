-- ============================================
-- Script d'initialisation : Création des schémas
-- ============================================

-- Schéma pour les données brutes (JSON)
CREATE SCHEMA IF NOT EXISTS raw;

-- Schéma pour les données aplaties/staging
CREATE SCHEMA IF NOT EXISTS staging;

-- Schéma pour les données analytiques finales
CREATE SCHEMA IF NOT EXISTS analytics;

-- Permissions (optionnel, déjà owner)
GRANT ALL ON SCHEMA raw TO jobmarket_user;
GRANT ALL ON SCHEMA staging TO jobmarket_user;
GRANT ALL ON SCHEMA analytics TO jobmarket_user;

-- Confirmation
DO $$
BEGIN
    RAISE NOTICE '✅ Schémas créés avec succès : raw, staging, analytics';
END $$;


