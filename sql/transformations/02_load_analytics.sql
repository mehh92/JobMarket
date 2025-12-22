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
    title_normalized,
    description,
    created,
    contract_type,
    contract_time,
    salary_min,
    salary_max,
    salary_avg,
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
    
    -- Titre normalisé (enlève H/F, F/H, parenthèses, tirets et catégorise)
    CASE
        -- ===== MÉTIERS TECHNIQUES DATA =====
        
        -- Data Engineer (toutes variantes : Engineer, Ingénieur, Pipeline, Ops, Integration, etc.)
        WHEN title ILIKE '%Data Engineer%' 
            OR title ILIKE '%Ingénieur%Data%' OR title ILIKE '%Ingenieur%Data%' 
            OR title ILIKE '%Data Ingénieur%' OR title ILIKE '%Data Ingenieur%'
            OR title ILIKE '%Data Pipeline%Engineer%'
            OR title ILIKE '%Data%Ops%Engineer%' OR title ILIKE '%Data-Ops%'
            OR title ILIKE '%Data Integration%Engineer%'
            OR title ILIKE '%Data Operations%Engineer%'
            OR title ILIKE '%Data Analytics%engineer%'
            OR title ILIKE '%Data/AI%engineer%' OR title ILIKE '%Data & AI%engineer%'
            OR title ILIKE '%Data%Platform%Engineer%'
            OR title ILIKE '%Senior Data%Engineer%' OR title ILIKE '%Lead%Data%Engineer%'
            OR title ILIKE '%Data/ IA engineer%' OR title ILIKE '%Data / ML Engineer%'
            OR title ILIKE '%Ingnieur-re Data Back-End%' OR title ILIKE '%Ingnieur-e Data%Systmes%'
            OR title ILIKE '%AI Engineer%Data%' OR title ILIKE '%Principal AI Engineer%'
            THEN 'Data Engineer'
        
        -- Data Scientist (toutes variantes)
        WHEN title ILIKE '%Data Scientist%' OR title ILIKE '%Scientifique%données%'
            OR title ILIKE '%Data Science%' AND title NOT ILIKE '%Manager%' AND title NOT ILIKE '%Assistant%'
            OR title ILIKE '%Principal%Data Science%'
            OR title ILIKE '%Senior Associate Scientist Data%'
            THEN 'Data Scientist'
        
        -- Data Analyst (toutes variantes)
        WHEN title ILIKE '%Data Analyst%' OR title ILIKE '%Analyste%Data%'
            OR title ILIKE '%Data Analys%' OR title ILIKE '%Data-analyst%'
            OR title ILIKE '%Data Analysis%'
            OR title ILIKE '%Charge%Etudes Data%' OR title ILIKE '%Chargé%Etudes Data%'
            OR title ILIKE '%Data And Product Analyst%' OR title ILIKE '%Senior UX Analyst%Data%'
            OR title ILIKE '%Chargé de data et performance%' OR title ILIKE '%Data Analytics Senior%'
            THEN 'Data Analyst'
        
        -- Business Analyst Data
        WHEN title ILIKE '%Business Analyst%Data%' OR title ILIKE '%BA Data%'
            OR title ILIKE '%Business Analytics%Data%'
            THEN 'Business Analyst Data'
        
        -- Développeur Data (Software Engineer, Fullstack, Developer)
        WHEN title ILIKE '%Développeur%Data%' OR title ILIKE '%Developpeur%Data%'
            OR title ILIKE '%Software Engineer%Data%' OR title ILIKE '%Data Software Engineer%'
            OR title ILIKE '%Fullstack%Data%' OR title ILIKE '%Data%Fullstack%'
            OR title ILIKE '%Data Developer%' OR title ILIKE '%Developer%Data%'
            OR title ILIKE '%Lead Developer%Data%'
            OR title ILIKE '%DATA DESIGNER%' OR title ILIKE '%Développement%Data%'
            OR title ILIKE '%Marketing%Data Automation%' OR title ILIKE '%Senior Product Design%Data%'
            OR title ILIKE '%Senior Product Designer Data Viz%' OR title ILIKE '%Senior Programmer Analyst%Data%'
            OR title ILIKE '%Chargé%Marketing Digital Data%Développement%'
            THEN 'Data Developer'
        
        -- ===== ARCHITECTURE & LEADERSHIP TECHNIQUE =====
        
        -- Data Architect (toutes variantes)
        WHEN title ILIKE '%Architecte%Data%' OR title ILIKE '%Data Architect%'
            OR title ILIKE '%Architecte Solution%Data%' OR title ILIKE '%Architecte Décisionnel%Data%'
            OR title ILIKE '%Architecte Azure%Data%' OR title ILIKE '%Data Cloud Architect%'
            OR title ILIKE '%Architecte%cloud%data%'
            OR title ILIKE '%Solution Architect%Data%' OR title ILIKE '%Cloud Solution Architect%Data%'
            OR title ILIKE '%Enterprise Data%Architect%' OR title ILIKE '%System Architect%Data%'
            OR title ILIKE '%Solution Architect%Generative AI Data%'
            THEN 'Data Architect'
        
        -- Tech Lead / Lead Data / Leader Technique
        WHEN title ILIKE '%Tech Lead%Data%' OR title ILIKE '%Lead%Data%' OR title ILIKE '%Data Lead%'
            OR title ILIKE '%Leader Technique%Data%' OR title ILIKE '%Lead Coordinateur%Data%'
            OR title ILIKE '%Data Hubs Lead%'
            OR title ILIKE '%Digital%Data Solution Tech Lead%' OR title ILIKE '%Data%Tech Lead%'
            OR title ILIKE '%Tech Lead Mulesoft%' OR title ILIKE '%Analytics%Tech Lead%Data%'
            OR title ILIKE '%Data transformation lead%' OR title ILIKE '%Data%Enabler%leader%'
            THEN 'Data Lead'
        
        -- ===== PRODUCT & PROJECT MANAGEMENT =====
        
        -- Data Product Manager/Owner (inclus AI/IA)
        WHEN title ILIKE '%Product Owner%Data%' OR title ILIKE '%Data Product Owner%' 
            OR title ILIKE '%Product Manager%Data%' OR title ILIKE '%Data Product Manager%'
            OR title ILIKE '%Data%AI Product Manager%' OR title ILIKE '%Data%IA Product Manager%'
            OR title ILIKE '%Data/AI Product Manager%' OR title ILIKE '%Data - AI Product Manager%'
            THEN 'Data Product Manager'
        
        -- Chef de Projet Data / Project Manager (toutes variantes)
        WHEN title ILIKE '%Chef%Projet%Data%' OR title ILIKE '%Chef%Projet%IA%'
            OR title ILIKE '%Data Project Manager%' OR title ILIKE '%Project Manager%Data%'
            OR title ILIKE '%Chargé%Projet%Data%' OR title ILIKE '%Charge%Projet%Data%'
            OR title ILIKE '%PMO%Data%' OR title ILIKE '%Data Project Officer%'
            OR title ILIKE '%Epic Owner%Data%'
            OR title ILIKE '%Data%Cloud Technical Project%' OR title ILIKE '%Technical Project%Data%'
            OR title ILIKE '%Scrum Master%Data%'
            OR title ILIKE '%Chef%Programme%Data%'
            THEN 'Data Project Manager'
        
        -- ===== GOUVERNANCE & QUALITÉ =====
        
        -- Data Quality
        WHEN title ILIKE '%Data Quality%' OR title ILIKE '%Qualité%Data%'
            OR title ILIKE '%Data Product Quality%' OR title ILIKE '%Data Management%Quality%'
            OR title ILIKE '%Data Integrity%' OR title ILIKE '%Auditeur%Data%'
            OR title ILIKE '%Inspecteur%Data%'
            THEN 'Data Quality'
        
        -- Data Governance / Data Steward
        WHEN title ILIKE '%Data Governance%' OR title ILIKE '%Data Steward%' OR title ILIKE '%Data Stewart%'
            OR title ILIKE '%Gouvernance%Data%' OR title ILIKE '%Master Data%'
            OR title ILIKE '%Expert%Data%Gouvernance%' OR title ILIKE '%Data Gouvernance%'
            OR title ILIKE '%Coordinateur Data Réglementaire%'
            OR title ILIKE '%Data Management%Governance%' OR title ILIKE '%Data Access Governance%'
            THEN 'Data Governance'
        
        -- Data Owner (nouveau - responsable métier des données)
        WHEN title ILIKE '%Data Owner%' OR title ILIKE '%Data Domain%'
            THEN 'Data Owner'
        
        -- Data Officer (nouveau - officier/responsable data)
        WHEN title ILIKE '%Data Officer%' AND title NOT ILIKE '%Privacy%' AND title NOT ILIKE '%Protection%'
            OR title ILIKE '%Référent%Data%'
            THEN 'Data Officer'
        
        -- Data Controller / Data Modeler (nouveau - contrôle et modélisation)
        WHEN title ILIKE '%Data Controller%' OR title ILIKE '%Data Modeler%' 
            OR title ILIKE '%Data contrôleur%' OR title ILIKE '%Customer Data Modeler%'
            OR title ILIKE '%Data Model%Lead%' OR title ILIKE '%Data modeling%'
            OR title ILIKE '%Financial Controller%Data%' OR title ILIKE '%Contrôleur%Data%'
            OR title ILIKE '%Data product Modélisation%'
            THEN 'Data Controller/Modeler'
        
        -- ===== LEGAL & COMPLIANCE =====
        
        -- Data Protection / Privacy / DPO / Avocat
        WHEN title ILIKE '%Data Protection%' OR title ILIKE '%DPO%' OR title ILIKE '%Data Privacy%'
            OR title ILIKE '%Juriste%Data%' OR title ILIKE '%Compliance%Data%'
            OR title ILIKE '%Avocat%Data%' OR title ILIKE '%Data%Compliance%'
            THEN 'Data Privacy/Legal'
        
        -- ===== MANAGEMENT & DIRECTION =====
        
        -- Directeur / VP / Chief Data
        WHEN title ILIKE '%Directeur%Data%' OR title ILIKE '%Director%Data%' 
            OR title ILIKE '%VP Data%' OR title ILIKE '%Chief Data%' OR title ILIKE '%Head of Data%'
            OR title ILIKE '%Responsable de%Data%' OR title ILIKE '%Data Office Director%'
            OR title ILIKE '%Data%Department Manager%' OR title ILIKE '%Departement Manager%Data%'
            OR title ILIKE '%Transformation%Data%Directeur%' OR title ILIKE '%Directeur%IA%'
            OR title ILIKE '%Responsable Architecture Data%'
            THEN 'Data Director'
        
        -- Manager Data (middle management - toutes variantes)
        WHEN title ILIKE '%Manager%Data%' OR title ILIKE '%Responsable%Data%' 
            OR title ILIKE '%Data Manager%' OR title ILIKE '%Data-manager%'
            OR title ILIKE '%Delivery Manager%Data%' OR title ILIKE '%Team Leader%Data%'
            OR title ILIKE '%Data Domain Manager%' OR title ILIKE '%Data Group Manager%'
            OR title ILIKE '%Gestionnaire%Data%' OR title ILIKE '%Gestionnaire Data%'
            OR title ILIKE '%Global Data%Manager%'
            OR title ILIKE '%Data Science Manager%' OR title ILIKE '%Data Analytics%Manager%'
            OR title ILIKE '%Data Management Officer%'
            OR title ILIKE '%CRM%Data Marketing Manager%' OR title ILIKE '%Chef%Groupe%Data%'
            OR title ILIKE '%Associate Manager%Data%' OR title ILIKE '%GTM%Data%Analytics Manager%'
            THEN 'Data Manager'
        
        -- ===== CONSEIL & STRATÉGIE =====
        
        -- Consultant Data (toutes variantes + Marketing & Strategy)
        WHEN title ILIKE '%Consultant%Data%' OR title ILIKE '%Conseil%Data%'
            OR title ILIKE '%Data Consultant%' OR title ILIKE '%Junior Data Consultant%'
            OR title ILIKE '%Senior Data Consultant%'
            OR title ILIKE '%Data Advisory%'
            OR title ILIKE '%Marketing%Data%Consult%' OR title ILIKE '%Data%Marketing%Consult%'
            OR title ILIKE '%Data%Strateg%Consult%'
            OR title ILIKE '%Solution Advisor%Data%' OR title ILIKE '%Data%Solution Advisor%'
            THEN 'Data Consultant'
        
        -- ===== SALES & BUSINESS DEVELOPMENT =====
        
        -- Sales / Business Developer Data/IA
        WHEN title ILIKE '%Sales%Data%' OR title ILIKE '%Business Dev%Data%' 
            OR title ILIKE '%Account Manager%Data%' OR title ILIKE '%Commercial%Data%'
            OR title ILIKE '%Account Strategist%Data%' OR title ILIKE '%Account Executive%Data%'
            OR title ILIKE '%Product Marketing%Data%' OR title ILIKE '%Product Marketing%IA%'
            THEN 'Data Sales'
        
        -- ===== BI / BUSINESS INTELLIGENCE =====
        
        WHEN title ILIKE '%BI%' OR title ILIKE '%Business Intelligence%'
            THEN 'BI Developer'
        
        -- ===== INFRASTRUCTURE & SYSTÈMES =====
        
        -- Database Administrator (DBA)
        WHEN title ILIKE '%Data Base Administrator%' OR title ILIKE '%Database Administrator%'
            OR title ILIKE '%DBA%' OR title ILIKE '%Administrateur%Base%Donnée%'
            OR title ILIKE '%Administrateur%Data%' AND title ILIKE '%Base%'
            OR title ILIKE '%Administrateur%Data%CRM%' OR title ILIKE '%Administrateur%SI%Data%'
            OR title ILIKE '%Administrateur ERP%Data%' OR title ILIKE '%Technicien%Data Management%'
            OR title ILIKE '%Technicien Support Data%' OR title ILIKE '%Learning Management System%Data Administrator%'
            THEN 'Database Administrator'
        
        -- Data Center (infrastructure physique)
        WHEN title ILIKE '%Data Center%' OR title ILIKE '%Data Centre%' 
            OR title ILIKE '%Datacenter%' OR title ILIKE '%Technicien%Data Center%'
            THEN 'Data Center (Infra)'
        
        -- Platform Engineer Data
        WHEN title ILIKE '%Platform Engineer%Data%' OR title ILIKE '%Data Platform%Engineer%'
            OR title ILIKE '%Data Storage%Engineer%'
            OR title ILIKE '%Staff Engineer%Data platform%' OR title ILIKE '%Solution Architect%Data Platform%'
            THEN 'Data Platform Engineer'
        
        -- ===== INTÉGRATION & OPÉRATIONS =====
        
        -- Intégrateur Data
        WHEN title ILIKE '%Intégrateur%Data%' OR title ILIKE '%Integrateur%Data%'
            OR title ILIKE '%Data Integration%' AND title NOT ILIKE '%Engineer%'
            OR title ILIKE '%Data Migration%'
            OR title ILIKE '%Data Intégration Engineer%'
            THEN 'Data Integrator'
        
        -- ===== EXPERTS & SPÉCIALISTES =====
        
        -- Expert Data (expertise technique pointue)
        WHEN title ILIKE '%Expert%Data%' OR title ILIKE '%Specialist%Data%' OR title ILIKE '%Spécialiste%Data%'
            OR title ILIKE '%Data Specialist%' OR title ILIKE '%Data Expert%'
            OR title ILIKE '%People data%systems specialist%' OR title ILIKE '%Power Platform Specialist%Data%'
            OR title ILIKE '%Data Management%Specialist%'
            THEN 'Data Expert'
        
        -- ===== ARCHITECTURE SI & URBANISME =====
        
        -- Urbaniste SI Data
        WHEN title ILIKE '%Urbaniste%Data%' OR title ILIKE '%Urbaniste%SI%Data%'
            THEN 'Data Urbanist'
        
        -- ===== QUALITÉ & TESTS =====
        
        -- Recetteur / Testeur Data
        WHEN title ILIKE '%Recetteur%Data%' OR title ILIKE '%Recette%Data%'
            OR title ILIKE '%Test%Data%' OR title ILIKE '%QA%Data%'
            THEN 'Data QA/Test'
        
        -- ===== AMOA & COORDINATEURS =====
        
        -- AMOA Data / Coordinateur
        WHEN title ILIKE '%AMOA%Data%' OR title ILIKE '%Coordinateur%Data%'
            OR title ILIKE '%Coordination%Data%'
            THEN 'Data Coordinator/AMOA'
        
        -- ===== SUPPORT & ASSISTANCE =====
        
        -- Assistant Data / Stagiaire / Alternance / Junior
        WHEN title ILIKE '%Assistant%Data%' OR title ILIKE '%Stagiaire%Data%' 
            OR title ILIKE '%Stage%Data%' OR title ILIKE '%STAGE%Data%'
            OR title ILIKE '%Alternance%Data%' OR title ILIKE '%ALTERNANCE%Data%'
            OR title ILIKE '%Intern%Data%' OR title ILIKE '%Data%Intern%'
            OR title ILIKE '%Apprentissage%Data%'
            OR (title ILIKE '%Junior%' AND title ILIKE '%Data%')
            OR title ILIKE '%Data%Junior%'
            THEN 'Data Junior/Stage'
        
        -- ===== MÉTIERS NON-DATA (exclusions) =====
        
        -- Data Entry / Saisie de données (métier de saisie, pas data métier)
        WHEN title ILIKE '%Data Entry%' OR title ILIKE '%Data Collector%' 
            OR title ILIKE '%Driver%Data%' OR title ILIKE '%Field Data Collection%'
            OR title ILIKE '%DATA COLLECTION MODERATOR%'
            THEN 'Data Entry/Collection (Hors IT)'
        
        -- Data Cabling / Infrastructure réseau physique
        WHEN title ILIKE '%Data Cabling%' OR title ILIKE '%Cabling%Data%'
            THEN 'Data Cabling (Hors IT)'
        
        -- Autres métiers avec "Data" dans contexte non-IT
        WHEN title ILIKE '%Technicien Data-Processing%' OR title ILIKE '%Data%Inspection%'
            OR title ILIKE '%Technicien Data%Nucléaire%'
            OR title ILIKE '%Air Data System%'  -- aéronautique
            OR title ILIKE '%Racing Data%'  -- automobile
            OR title ILIKE '%Comptable%Data%' OR title ILIKE '%Collaborateur Comptable%Data%'
            THEN 'Data (Hors IT)'
        
        -- ===== AUTRES RÔLES DATA (IT) =====
        
        -- Data générique (contient "Data" mais aucune catégorie ci-dessus)
        WHEN title ILIKE '%Data%'
            THEN 'Data (Autre)'
        
        -- Par défaut (ne contient même pas "Data")
        ELSE 'Autre'
    END AS title_normalized,
    
    description,
    created,
    
    -- Contrat
    contract_type,
    contract_time,
    
    -- Salaires (avec calculs)
    salary_min,
    salary_max,
    (salary_min + salary_max) / 2 AS salary_avg,
    
    -- Localisation
    latitude,
    longitude,
    location_display,
    country,
    region,
    department,
    city,
    
    -- Entreprise et catégorie
    company_name,
    category_label,
    category_tag,
    
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
    title_normalized = EXCLUDED.title_normalized,
    description = EXCLUDED.description,
    created = EXCLUDED.created,
    salary_min = EXCLUDED.salary_min,
    salary_max = EXCLUDED.salary_max,
    salary_avg = EXCLUDED.salary_avg,
    location_display = EXCLUDED.location_display,
    company_name = EXCLUDED.company_name,
    year = EXCLUDED.year,
    month = EXCLUDED.month,
    year_month = EXCLUDED.year_month;
