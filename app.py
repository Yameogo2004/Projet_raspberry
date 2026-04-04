from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta
import random

app = Flask(__name__)
CORS(app)

# ========== ROUTES DE BASE ==========

@app.route('/')
def accueil():
    return jsonify({"message": "Mon API Parking fonctionne !"})

# ========== STATUT PARKING ==========

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

@app.route('/api/parking/statut-par-niveau', methods=['GET'])
def get_statut_par_niveau():
    return jsonify([
        {"niveau": 0, "libelle": "Rez-de-chaussée", "libres": 8, "total": 12},
        {"niveau": 1, "libelle": "Étage 1", "libres": 5, "total": 12},
        {"niveau": 2, "libelle": "Étage 2", "libres": 3, "total": 12},
    ])

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
    
    # Utilisateur test
    if email == 'test@test.com' and password == 'password':
        return jsonify({
            "success": True,
            "token": "fake_token_123",
            "user_id": 1,
            "user": {
                "id": 1,
                "nom": "Dupont",
                "prenom": "Jean",
                "email": "test@test.com",
                "role": "user"
            }
        })
    
    return jsonify({"success": False, "error": "Email ou mot de passe incorrect"}), 401

@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.json
    return jsonify({
        "success": True,
        "user_id": random.randint(100, 999),
        "message": "Inscription réussie"
    })

@app.route('/api/auth/me', methods=['GET'])
def get_current_user():
    return jsonify({
        "user": {
            "id": 1,
            "nom": "Dupont",
            "prenom": "Jean",
            "email": "test@test.com",
            "role": "user"
        }
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

# ========== RÉSERVATION ==========

@app.route('/api/reservation', methods=['POST'])
def create_reservation():
    data = request.json
    
    distance = data.get('distance', 0)
    temps_trajet = data.get('temps_trajet', 0)
    charge = data.get('charge', 0)
    
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

# ========== ANNULER RÉSERVATION ==========
@app.route('/api/reservation/<int:reservation_id>/annuler', methods=['POST'])
def annuler_reservation(reservation_id):
    # Simuler l'annulation
    return jsonify({
        "success": True,
        "message": "Réservation annulée avec succès",
        "reservation_id": reservation_id
    })

# ========== PAIEMENT ==========
@app.route('/api/payment/process', methods=['POST'])
def process_payment():
    data = request.json
    montant = data.get('montant')
    reservation_id = data.get('reservation_id')
    reservation_code = data.get('reservation_code')
    payment_method = data.get('payment_method')
    
    # Simuler un paiement réussi
    import uuid
    transaction_id = str(uuid.uuid4())[:8].upper()
    
    return jsonify({
        "success": True,
        "transaction_id": transaction_id,
        "message": "Paiement effectué avec succès",
        "montant": montant,
        "reservation_id": reservation_id
    })

# ========== STATIONNEMENT ACTIF ==========
# Par défaut : AUCUN véhicule garé (affiche les places libres)
# Pour simuler un véhicule garé, changer has_active: False → True
@app.route('/api/stationnement/actif', methods=['GET'])
def get_stationnement_actif():
    # ⚠️ CHANGER False → True POUR SIMULER UN VÉHICULE GARÉ
    return jsonify({
        "has_active": False,  # ← False = places libres, True = véhicule garé
        "stationnement": None
    })




# ========== PROLONGER STATIONNEMENT ==========

@app.route('/api/stationnement/prolonger', methods=['POST'])
def prolonger_stationnement():
    data = request.json
    heures_supplementaires = data.get('heures_supplementaires', 0)
    minutes_supplementaires = data.get('minutes_supplementaires', 0)
    
    total_heures = heures_supplementaires + (minutes_supplementaires / 60)
    prix_par_heure = 2.50
    montant_supplementaire = total_heures * prix_par_heure
    
    return jsonify({
        "success": True,
        "message": f"Stationnement prolongé de {heures_supplementaires}h{minutes_supplementaires}min",
        "heures_ajoutees": heures_supplementaires,
        "minutes_ajoutees": minutes_supplementaires,
        "montant_supplementaire": round(montant_supplementaire, 2)
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


# ========== HISTORIQUE RÉSERVATIONS ==========
@app.route('/api/reservations/historique', methods=['GET'])
def get_reservations_historique():
    # Simuler l'historique
    return jsonify({
        "reservations": [
            {
                "id": 1,
                "code_confirmation": "RES1001",
                "date_reservation": (datetime.now() - timedelta(days=5)).isoformat(),
                "date_debut": (datetime.now() - timedelta(days=3)).isoformat(),
                "date_fin": (datetime.now() - timedelta(days=3) + timedelta(hours=4)).isoformat(),
                "plaque": "AB-123-CD",
                "modele": "Tesla Model 3",
                "charge": 200,
                "montant": 12.50,
                "statut": "terminée",
                "emplacement": "Niveau 1 - Box A2"
            }
        ]
    })

# ========== LISTE NOIRE ==========

@app.route('/api/liste_noire/ajouter', methods=['POST'])
def ajouter_liste_noire():
    data = request.json
    return jsonify({
        "success": True,
        "message": "Plaque ajoutée à la liste noire"
    })

@app.route('/api/liste_noire/supprimer', methods=['POST'])
def supprimer_liste_noire():
    data = request.json
    return jsonify({
        "success": True,
        "message": "Plaque retirée de la liste noire"
    })

# ========== LANCEMENT ==========

if __name__ == '__main__':
    print("=" * 50)
    print("🚗 Parking Intelligent API")
    print("=" * 50)
    print("📍 http://localhost:5000")
    print("\n📋 Mode: has_active = False (aucun véhicule garé)")
    print("   → L'application affiche les places libres")
    print("\n🔥 API démarrée...")
    app.run(debug=True, port=5000)