-- ============================================
-- Création de la base de données Airflow
-- Ce script crée la DB et l'utilisateur pour
-- le métastore d'Airflow (séparé de jobmarket)
-- ============================================

-- Créer l'utilisateur airflow
DO
$$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'airflow') THEN
        CREATE USER airflow WITH PASSWORD 'airflow';
        RAISE NOTICE 'Utilisateur airflow créé';
    ELSE
        RAISE NOTICE 'Utilisateur airflow existe déjà';
    END IF;
END
$$;

-- Créer la base de données airflow (si elle n'existe pas)
-- Note: CREATE DATABASE ne peut pas être dans un bloc transactionnel
-- On utilise une condition pour éviter l'erreur si elle existe déjà

SELECT 'CREATE DATABASE airflow OWNER airflow'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'airflow')\gexec

-- Donner tous les privilèges à l'utilisateur airflow sur sa base
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

-- Log de confirmation
\echo '✅ Base de données Airflow créée et configurée'

