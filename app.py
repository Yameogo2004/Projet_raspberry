from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Important pour que l'app Flutter puisse communiquer

@app.route('/')
def accueil():
    return jsonify({"message": "Mon API Parking fonctionne !"})

@app.route('/api/parking/statut')
def statut():
    return jsonify({
        "places_libres": 10,
        "places_occupees": 5,
        "total_places": 15,
        "taux_occupation": 33.33,
        "entrees_jour": 42,
        "ca_jour": 1250
    })

# ========== AUTHENTIFICATION ==========

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.json
    email = data.get('email')
    password = data.get('password')


    
    # Admin
    if email == 'admin@parking.com' and password == 'admin123':
        return jsonify({
            "success": True,
            "token": "fake_token_admin",
            "user_id": 2,
            "user": {
                "id": 2,
                "nom": "Admin",
                "prenom": "Système",
                "email": "admin@parking.com",
                "role": "admin"
            }
        })
    
    # Test simple (vous pourrez remplacer par base de données plus tard)
    if email == 'test@test.com' and password == 'password':
        return jsonify({
            "success": True,
            "token": "fake_token_123",
            "user_id": 1,
            "user": {
                "id": 1,
                "nom": "Dupont",
                "prenom": "Jean",
                "email": "test@test.com"
            }
        })
    else:
        return jsonify({"success": False, "error": "Email ou mot de passe incorrect"}), 401

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.json
    # Simuler inscription
    return jsonify({
        "success": True,
        "user_id": 2,
        "message": "Inscription réussie"
    })

# ========== VEHICULES ==========

@app.route('/api/vehicules', methods=['GET'])
def get_vehicules():
    return jsonify({
        "vehicules": [
            {
                "id": 1,
                "plaque": "AB-123-CD",
                "modele": "Tesla Model 3",
                "marque": "Tesla",
                "poids_a_vide": 1800,
                "charge_max": 400,
                "couleur": "Bleu"
            },
            {
                "id": 2,
                "plaque": "EF-456-GH",
                "modele": "Renault Zoe",
                "marque": "Renault",
                "poids_a_vide": 1500,
                "charge_max": 300,
                "couleur": "Blanc"
            }
        ]
    })

# ========== RESERVATION ==========

@app.route('/api/reservation', methods=['POST'])
def create_reservation():
    data = request.json
    return jsonify({
        "success": True,
        "reservation_id": 123,
        "message": "Réservation créée avec succès",
        "code_confirmation": "RES123456"
    })

# ========== STATIONNEMENT ACTIF ==========

@app.route('/api/stationnement/actif', methods=['GET'])
def get_stationnement_actif():
    # Simuler un stationnement actif
    return jsonify({
        "has_active": True,
        "stationnement": {
            "id": 1,
            "date_entree": datetime.now().isoformat(),
            "plaque": "AB-123-CD",
            "niveau": 1,
            "place_numero": 12,
            "qr_code": "PARKING:AB-123-CD:1:12:20250403",
            "rfid_ticket": "RFID:AB123CD:001",
            "emplacement": "Niveau 1 - Place 12"
        }
    })

# ========== STATUT PARKING PAR NIVEAU ==========

@app.route('/api/parking/statut-par-niveau', methods=['GET'])
def get_statut_par_niveau():
    return jsonify([
        {"niveau": 0, "places_libres": 8, "places_occupees": 4, "total_places": 12},
        {"niveau": 1, "places_libres": 5, "places_occupees": 7, "total_places": 12},
        {"niveau": 2, "places_libres": 3, "places_occupees": 9, "total_places": 12},
    ])

# ========== RÉSERVATION AMÉLIORÉE ==========

@app.route('/api/reservation', methods=['POST'])
def create_reservation_amelioree():
    data = request.json
    
    # Récupérer les infos de localisation
    distance = data.get('distance', 0)
    temps_trajet = data.get('temps_trajet', 0)
    charge = data.get('charge', 0)
    
    # Créer réservation
    reservation_id = random.randint(1000, 9999)
    
    return jsonify({
        "success": True,
        "reservation_id": reservation_id,
        "message": f"Réservation créée - Distance: {distance}km, Arrivée dans {temps_trajet}min",
        "code_confirmation": f"RES{reservation_id}",
        "distance": distance,
        "temps_trajet": temps_trajet,
        "heure_arrivee_estimee": (datetime.now() + timedelta(minutes=temps_trajet)).strftime("%H:%M")
    })

# ========== LOCALISATION ==========

@app.route('/api/vehicule/<plaque>/localisation', methods=['GET'])
def localiser_vehicule(plaque):
    return jsonify({
        "trouve": True,
        "niveau": 1,
        "place": 12,
        "message": f"Votre véhicule {plaque} est au niveau 1, place 12"
    })

if __name__ == '__main__':
    app.run(debug=True, port=5000)