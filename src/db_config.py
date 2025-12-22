"""
Configuration centralisée pour la connexion PostgreSQL
"""

import os
from typing import Dict

def get_db_config() -> Dict[str, str]:
    """
    Récupère la configuration de connexion à PostgreSQL
    Supporte les variables d'environnement (Docker) et config locale
    
    Returns:
        Dict contenant host, port, database, user, password
    """
    return {
        'host': os.getenv('JOBMARKET_DB_HOST', 'localhost'),
        'port': int(os.getenv('JOBMARKET_DB_PORT', 5432)),
        'database': os.getenv('JOBMARKET_DB_NAME', 'jobmarket'),
        'user': os.getenv('JOBMARKET_DB_USER', 'jobmarket_user'),
        'password': os.getenv('JOBMARKET_DB_PASSWORD', 'jobmarket_pass')
    }

def get_connection_string() -> str:
    """
    Retourne la chaîne de connexion PostgreSQL
    
    Returns:
        String de connexion format: postgresql://user:pass@host:port/db
    """
    config = get_db_config()
    return f"postgresql://{config['user']}:{config['password']}@{config['host']}:{config['port']}/{config['database']}"

