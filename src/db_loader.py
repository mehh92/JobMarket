"""
Module de chargement des données JSON dans PostgreSQL
"""

import json
import psycopg2
from psycopg2.extras import execute_batch
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime
import logging

from db_config import get_db_config

# Configuration du logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class JobMarketLoader:
    """
    Classe pour charger les données d'offres d'emploi dans PostgreSQL
    """
    
    def __init__(self, db_config: Optional[Dict] = None):
        """
        Initialise le loader avec la configuration DB
        
        Args:
            db_config: Configuration DB (si None, utilise get_db_config())
        """
        self.db_config = db_config or get_db_config()
        self.conn = None
        self.cur = None
        
    def connect(self):
        """Établit la connexion à PostgreSQL"""
        try:
            logger.info(f"🔄 Connexion à PostgreSQL : {self.db_config['host']}:{self.db_config['port']}/{self.db_config['database']}")
            self.conn = psycopg2.connect(**self.db_config)
            self.cur = self.conn.cursor()
            logger.info("✅ Connexion établie")
        except psycopg2.Error as e:
            logger.error(f"❌ Erreur de connexion : {e}")
            raise
    
    def close(self):
        """Ferme la connexion"""
        if self.cur:
            self.cur.close()
        if self.conn:
            self.conn.close()
        logger.info("🔒 Connexion fermée")
    
    def load_json_file(self, json_path: Path) -> Dict:
        """
        Charge le fichier JSON
        
        Args:
            json_path: Chemin vers le fichier JSON
            
        Returns:
            Dict contenant metadata et jobs
        """
        logger.info(f"📂 Chargement du fichier : {json_path}")
        
        if not json_path.exists():
            raise FileNotFoundError(f"Fichier introuvable : {json_path}")
        
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        nb_jobs = len(data.get('jobs', []))
        logger.info(f"✅ {nb_jobs} offres chargées depuis le JSON")
        
        return data
    
    def insert_metadata(self, metadata: Dict) -> int:
        """
        Insère les métadonnées de l'import
        
        Args:
            metadata: Dict contenant search_term, total_jobs, etc.
            
        Returns:
            ID de l'import créé
        """
        query = """
            INSERT INTO raw.import_metadata (search_term, total_jobs, scraping_date, api_source)
            VALUES (%s, %s, %s, %s)
            RETURNING id;
        """
        
        scraping_date = datetime.fromisoformat(metadata.get('scraping_date', datetime.now().isoformat()))
        
        self.cur.execute(query, (
            metadata.get('search_term'),
            metadata.get('total_jobs'),
            scraping_date,
            metadata.get('api_source', 'Adzuna')
        ))
        
        import_id = self.cur.fetchone()[0]
        logger.info(f"✅ Métadonnées insérées (import_id: {import_id})")
        
        return import_id
    
    def insert_jobs(self, jobs: List[Dict]) -> int:
        """
        Insère les offres d'emploi dans raw.jobs_raw
        
        Args:
            jobs: Liste des offres d'emploi
            
        Returns:
            Nombre d'offres insérées
        """
        if not jobs:
            logger.warning("⚠️ Aucune offre à insérer")
            return 0
        
        logger.info(f"🔄 Insertion de {len(jobs)} offres...")
        
        # Préparer les données pour l'insertion batch
        insert_query = """
            INSERT INTO raw.jobs_raw (job_id, data, source)
            VALUES (%s, %s, %s)
            ON CONFLICT (job_id) 
            DO UPDATE SET 
                data = EXCLUDED.data,
                updated_at = CURRENT_TIMESTAMP;
        """
        
        batch_data = [
            (
                job.get('id'),
                json.dumps(job),
                'adzuna'
            )
            for job in jobs
        ]
        
        # Insertion par batch de 1000
        execute_batch(self.cur, insert_query, batch_data, page_size=1000)
        
        logger.info(f"✅ {len(batch_data)} offres insérées/mises à jour dans raw.jobs_raw")
        
        return len(batch_data)
    
    def load_from_json(self, json_path: Path) -> Dict[str, int]:
        """
        Charge un fichier JSON complet dans PostgreSQL
        
        Args:
            json_path: Chemin vers le fichier JSON
            
        Returns:
            Dict avec statistiques (import_id, nb_jobs_inserted)
        """
        try:
            # Charger le JSON
            data = self.load_json_file(json_path)
            
            # Connexion DB
            self.connect()
            
            # Insérer les métadonnées
            import_id = self.insert_metadata(data['metadata'])
            
            # Insérer les jobs
            nb_inserted = self.insert_jobs(data['jobs'])
            
            # Commit
            self.conn.commit()
            
            logger.info(f"✅ Import terminé avec succès !")
            logger.info(f"   📊 Import ID: {import_id}")
            logger.info(f"   📋 Offres insérées: {nb_inserted}")
            
            return {
                'import_id': import_id,
                'nb_jobs_inserted': nb_inserted,
                'success': True
            }
            
        except Exception as e:
            if self.conn:
                self.conn.rollback()
            logger.error(f"❌ Erreur lors de l'import : {e}")
            raise
        
        finally:
            self.close()


def main():
    """
    Fonction principale pour tester le loader
    """
    # Chemin vers le fichier JSON (relatif au script)
    project_root = Path(__file__).parent.parent
    json_path = project_root / "data" / "jobs_data.json"
    
    logger.info("=" * 60)
    logger.info("🚀 CHARGEMENT DES DONNÉES DANS POSTGRESQL")
    logger.info("=" * 60)
    
    # Créer le loader et charger les données
    loader = JobMarketLoader()
    result = loader.load_from_json(json_path)
    
    if result['success']:
        logger.info("\n" + "=" * 60)
        logger.info("✅ SUCCÈS - Données chargées dans PostgreSQL")
        logger.info("=" * 60)
        logger.info(f"📊 Statistiques :")
        logger.info(f"   • Import ID: {result['import_id']}")
        logger.info(f"   • Offres insérées: {result['nb_jobs_inserted']}")
        logger.info("\n💡 Prochaine étape : Exécuter les transformations SQL")
    else:
        logger.error("❌ ÉCHEC - Vérifiez les logs ci-dessus")


if __name__ == "__main__":
    main()

