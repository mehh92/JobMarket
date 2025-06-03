import requests
import json
import time

#Authentification
client_id = "Your_client_id_here"
client_secret = "Your_client_secret_here"

scope = "api_offresdemploiv2 o2dsoffre"
auth_url = "https://entreprise.pole-emploi.fr/connexion/oauth2/access_token?realm=/partenaire"

auth_data = {
    "grant_type": "client_credentials",
    "client_id": client_id,
    "client_secret": client_secret,
    "scope": scope
}

auth_response = requests.post(auth_url, data=auth_data)
token = auth_response.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

#Paramètres
codes_rome = ["M1802","M1803","M1804","M1805","M1806","M1807","M1810", "M1811"]
par_page = 150

all_offres = []

#Récupération des offres
for code in codes_rome:
    print(f"🔍 Téléchargement des offres pour le code ROME {code}...")
    page = 0
    while True:
        range_start = page * par_page
        range_end = range_start + par_page - 1
        params = {
            "tempsPlein": "true",
            "codeROME": code,
            "range": f"{range_start}-{range_end}"
        }

        url = "https://api.pole-emploi.io/partenaire/offresdemploi/v2/offres/search"
        response = requests.get(url, headers=headers, params=params)

        if response.status_code in [200, 206]:
            offres = response.json().get("resultats", [])
            if not offres:
                print(f"✅ Terminé pour {code}, aucune nouvelle offre à partir de la page {page}")
                break
            all_offres.extend(offres)
            print(f"📄 Page {page + 1} : {len(offres)} offres récupérées")
        else:
            print(f"❌ Erreur {response.status_code} sur la page {page + 1}")
            break

        page += 1
        time.sleep(1)

#Sauvegarde
with open("offres_emploi_FT_IT.json", "w", encoding="utf-8") as f:
    json.dump(all_offres, f, ensure_ascii=False, indent=2)

print(f"🎉 Terminé ! {len(all_offres)} offres enregistrées dans offres_emploi_FT_IT.json")
