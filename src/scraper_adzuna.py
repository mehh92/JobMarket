"""
Scraper pour récupérer les offres d'emploi depuis l'API Adzuna
"""

import requests
import json
import time
import os
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any, Optional


class AdzunaJobScraper:
    """
    Scraper pour récupérer toutes les offres d'emploi depuis l'API Adzuna
    """
    
    def __init__(self, app_id: str, app_key: str, base_url: str = "http://api.adzuna.com/v1/api/jobs/fr/search"):
        self.app_id = app_id
        self.app_key = app_key
        self.base_url = base_url
        self.results_per_page = 50
        self.session = requests.Session()
        
        # Définir le répertoire racine du projet (parent de src/)
        self.project_root = Path(__file__).parent.parent
        self.data_dir = self.project_root / "data"
        
        # Créer le répertoire data s'il n'existe pas
        self.data_dir.mkdir(exist_ok=True)
        
    def get_jobs_page(self, page: int, search_term: str = "data") -> Optional[Dict[str, Any]]:
        """
        Récupère une page spécifique d'offres d'emploi
        
        Args:
            page: Numéro de la page (commence à 1)
            search_term: Terme de recherche
            
        Returns:
            Réponse JSON de l'API ou None en cas d'erreur
        """
        url = f"{self.base_url}/{page}"
        params = {
            'app_id': self.app_id,
            'app_key': self.app_key,
            'results_per_page': self.results_per_page,
            'what': search_term
        }
        
        try:
            response = self.session.get(url, params=params, timeout=30)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Erreur lors de la requête page {page}: {e}")
            return None
    
    def scrape_all_jobs(self, search_term: str = "data", max_pages: Optional[int] = None, delay: float = 1.0) -> List[Dict[str, Any]]:
        """
        Récupère toutes les offres d'emploi en parcourant toutes les pages
        
        Args:
            search_term: Terme de recherche
            max_pages: Nombre maximum de pages à récupérer (None = toutes)
            delay: Délai en secondes entre les requêtes
            
        Returns:
            Liste de toutes les offres d'emploi
        """
        all_jobs = []
        page = 1
        total_results = None
        
        print(f"Début du scraping pour le terme: '{search_term}'")
        
        while True:
            if max_pages and page > max_pages:
                print(f"Limite de pages atteinte: {max_pages}")
                break
                
            print(f"Récupération de la page {page}...")
            
            response_data = self.get_jobs_page(page, search_term)
            
            if not response_data:
                print(f"Erreur lors de la récupération de la page {page}")
                break
            
            # Récupérer les informations sur le total la première fois
            if total_results is None:
                total_results = response_data.get('count', 0)
                total_pages = (total_results + self.results_per_page - 1) // self.results_per_page
                print(f"Total d'offres trouvées: {total_results}")
                print(f"Nombre total de pages: {total_pages}")
            
            # Récupérer les offres de cette page
            jobs = response_data.get('results', [])
            
            if not jobs:
                print(f"Aucune offre trouvée sur la page {page}. Fin du scraping.")
                break
            
            all_jobs.extend(jobs)
            print(f"Page {page}: {len(jobs)} offres récupérées (Total: {len(all_jobs)})")
            
            # Vérifier si c'est la dernière page
            if len(jobs) < self.results_per_page:
                print("Dernière page atteinte.")
                break
            
            page += 1
            
            # Délai entre les requêtes pour éviter de surcharger l'API
            if delay > 0:
                time.sleep(delay)
        
        print(f"Scraping terminé. Total d'offres récupérées: {len(all_jobs)}")
        return all_jobs
    
    def save_to_json(self, jobs: List[Dict[str, Any]], filename: Optional[str] = None, search_term: str = "data") -> Path:
        """
        Sauvegarde les offres d'emploi dans un fichier JSON
        
        Args:
            jobs: Liste des offres d'emploi
            filename: Nom du fichier (optionnel, par défaut jobs_{search_term}.json)
            search_term: Terme de recherche utilisé
            
        Returns:
            Chemin Path du fichier sauvegardé
        """
        if filename is None:
            filename = f"jobs_{search_term}.json"
        
        # Utiliser le répertoire data/ du projet
        filepath = self.data_dir / filename
        
        # Préparer les données à sauvegarder
        output_data = {
            "metadata": {
                "search_term": search_term,
                "total_jobs": len(jobs),
                "scraping_date": datetime.now().isoformat(),
                "api_source": "Adzuna"
            },
            "jobs": jobs
        }
        
        # Sauvegarder en JSON
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, ensure_ascii=False, indent=2)
        
        print(f"Données sauvegardées dans: {filepath}")
        return filepath


def load_config(config_path: Optional[Path] = None) -> Optional[Dict]:
    """
    Charge la configuration depuis le fichier config.json
    
    Args:
        config_path: Chemin vers le fichier config.json (optionnel)
    
    Returns:
        dict: Configuration avec les clés API ou None en cas d'erreur
    """
    if config_path is None:
        # Chercher config.json dans le dossier src/
        src_dir = Path(__file__).parent
        config_path = src_dir / "config.json"
    
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            config = json.load(f)
        return config
    except FileNotFoundError:
        print(f"ERREUR: Fichier de configuration non trouvé: {config_path}")
        print("Créez un fichier config.json basé sur config.example.adzuna.json")
        print(f"Le fichier doit être placé dans le dossier src/: {config_path}")
        return None
    except json.JSONDecodeError as e:
        print(f"ERREUR: Le fichier config.json n'est pas un JSON valide: {e}")
        return None


def main():
    """
    Fonction principale pour exécuter le scraping
    """
    # Charger la configuration
    config = load_config()
    if not config:
        return
    
    # Récupérer les clés API
    adzuna_config = config.get('adzuna', {})
    APP_ID = adzuna_config.get('app_id')
    APP_KEY = adzuna_config.get('app_key')
    
    if not APP_ID or not APP_KEY:
        print("ERREUR: Clés API manquantes dans le fichier config.json")
        print("Vérifiez que app_id et app_key sont présents dans la section 'adzuna'")
        return
    
    
    # Paramètres de recherche
    search_term = "data"  # Terme de recherche
    max_pages = 700  # None = toutes les pages, ou définir un nombre pour limiter
    delay = 0.2  # Délai en secondes entre les requêtes
    
    # Créer le scraper
    scraper = AdzunaJobScraper(APP_ID, APP_KEY)
    
    try:
        # Récupérer toutes les offres
        all_jobs = scraper.scrape_all_jobs(
            search_term=search_term,
            max_pages=max_pages,
            delay=delay
        )
        
        if all_jobs:
            # Sauvegarder les résultats
            filepath = scraper.save_to_json(all_jobs, search_term=search_term)
            print(f"\n✅ Scraping terminé avec succès!")
            print(f"📊 Nombre total d'offres: {len(all_jobs)}")
            print(f"💾 Fichier sauvegardé: {filepath}")
        else:
            print("Aucune offre récupérée.")
            
    except KeyboardInterrupt:
        print("\n⚠️ Scraping interrompu par l'utilisateur.")
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()

