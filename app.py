from flask import Flask, jsonify, request
from flask_cors import CORS
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)

# =========================================================
# DONNÉES MOCK TEMPORAIRES V2
# =========================================================

USERS = [
    {
        "id": 1,
        "nom": "Dupont",
        "prenom": "Jean",
        "email": "test@test.com",
        "telephone": "0600000001",
        "password": "password",
        "role": "client",
    },
    {
        "id": 2,
        "nom": "Admin",
        "prenom": "Système",
        "email": "admin@parking.com",
        "telephone": "0600000002",
        "password": "admin123",
        "role": "admin",
    },
]

ALERTES = [
    {
        "id": 1,
        "type": "Intrusion vehicule",
        "message": "Tentative d'accès non autorisée détectée à l'entrée secondaire.",
        "niveau": "Critique",
        "resolue": False,
        "commentaire": "",
        "source": "Contrôle accès",
        "parking_level": "Niveau 0",
        "spot_code": "Entrée secondaire",
        "vehicule_matricule": "44556-D-2",
        "capteur_nom": "Caméra entrée sud",
        "timestamp": (datetime.now() - timedelta(minutes=8)).isoformat(),
    },
    {
        "id": 2,
        "type": "Capteur",
        "message": "Le capteur de présence du niveau 1 ne répond plus.",
        "niveau": "Warning",
        "resolue": False,
        "commentaire": "",
        "source": "Monitoring capteurs",
        "parking_level": "Niveau 1",
        "spot_code": "P1-02",
        "vehicule_matricule": None,
        "capteur_nom": "Capteur présence P1-02",
        "timestamp": (datetime.now() - timedelta(minutes=16)).isoformat(),
    },
    {
        "id": 3,
        "type": "Paiement",
        "message": "Un paiement a été refusé pour la session #205.",
        "niveau": "Info",
        "resolue": False,
        "commentaire": "",
        "source": "Passerelle paiement",
        "parking_level": "Niveau 0",
        "spot_code": "P0-02",
        "vehicule_matricule": "12345-A-6",
        "capteur_nom": None,
        "timestamp": (datetime.now() - timedelta(minutes=22)).isoformat(),
    },
]

CAPTEURS = [
    {"id": 1, "type": "RFID", "statut": "online"},
    {"id": 2, "type": "Caméra", "statut": "online"},
    {"id": 3, "type": "Poids", "statut": "offline"},
    {"id": 4, "type": "Présence", "statut": "online"},
    {"id": 5, "type": "Barrière", "statut": "error"},
]

VEHICULES = [
    {"id": 1, "matricule": "12345-A-6", "type": "SUV", "modele": "Peugeot 3008"},
    {"id": 2, "matricule": "67890-B-1", "type": "Citadine", "modele": "Renault Clio"},
    {"id": 3, "matricule": "11223-C-7", "type": "Berline", "modele": "Tesla Model 3"},
    {"id": 4, "matricule": "44556-D-2", "type": "Utilitaire", "modele": "Ford Transit"},
    {"id": 5, "matricule": "99887-X-3", "type": "Électrique", "modele": "Renault Zoe"},
]

PARKING_SPOTS = [
    {"id": 1, "numero": "P0-01", "statut": "Libre", "type": "standard"},
    {"id": 2, "numero": "P0-02", "statut": "Occupée", "type": "standard"},
    {"id": 3, "numero": "P0-03", "statut": "Libre", "type": "handicape"},
    {"id": 4, "numero": "P0-04", "statut": "Réservée", "type": "VIP"},
    {"id": 5, "numero": "P1-01", "statut": "Occupée", "type": "standard"},
    {"id": 6, "numero": "P1-02", "statut": "Occupée", "type": "electrique"},
    {"id": 7, "numero": "P1-03", "statut": "Libre", "type": "standard"},
    {"id": 8, "numero": "P1-04", "statut": "Libre", "type": "VIP"},
    {"id": 9, "numero": "P2-01", "statut": "Occupée", "type": "standard"},
    {"id": 10, "numero": "P2-02", "statut": "Libre", "type": "electrique"},
    {"id": 11, "numero": "P2-03", "statut": "Occupée", "type": "standard"},
    {"id": 12, "numero": "P2-04", "statut": "Libre", "type": "standard"},
]

STATIONNEMENTS = [
    {
        "id": 101,
        "vehicle_id": 1,
        "parking_spot_id": 2,
        "entree": (datetime.now() - timedelta(hours=2)).isoformat(),
        "sortie": None,
        "user_id": 1,
    },
    {
        "id": 102,
        "vehicle_id": 2,
        "parking_spot_id": 5,
        "entree": (datetime.now() - timedelta(hours=5)).isoformat(),
        "sortie": None,
        "user_id": 1,
    },
    {
        "id": 103,
        "vehicle_id": 3,
        "parking_spot_id": 9,
        "entree": (datetime.now() - timedelta(hours=7)).isoformat(),
        "sortie": (datetime.now() - timedelta(hours=1)).isoformat(),
        "user_id": 1,
    },
]

RESERVATIONS_HISTORY = [
    {
        "id": 1001,
        "user_id": 1,
        "code_confirmation": "RES1001",
        "date_reservation": (datetime.now() - timedelta(days=5)).isoformat(),
        "date_debut": (datetime.now() - timedelta(days=3)).isoformat(),
        "date_fin": (datetime.now() - timedelta(days=3) + timedelta(hours=4)).isoformat(),
        "plaque": "AB-123-CD",
        "modele": "Tesla Model 3",
        "charge": 200,
        "montant": 12.50,
        "statut": "confirmée",
        "emplacement": "Niveau 1 - Box A2",
    },
    {
        "id": 1002,
        "user_id": 1,
        "code_confirmation": "RES1002",
        "date_reservation": (datetime.now() - timedelta(days=10)).isoformat(),
        "date_debut": (datetime.now() - timedelta(days=8)).isoformat(),
        "date_fin": (datetime.now() - timedelta(days=8) + timedelta(hours=2)).isoformat(),
        "plaque": "EF-456-GH",
        "modele": "Renault Zoe",
        "charge": 100,
        "montant": 6.50,
        "statut": "terminée",
        "emplacement": "Niveau 0 - Box B3",
    },
]

PAIEMENTS = [
    {"id": 201, "montant": 20.0, "statut": "paid"},
    {"id": 202, "montant": 12.5, "statut": "pending"},
    {"id": 203, "montant": 35.0, "statut": "paid"},
    {"id": 204, "montant": 18.0, "statut": "failed"},
]

PARKING_PAYMENTS = [
    {"id": 301, "montant": 25.0, "statut": "paid"},
    {"id": 302, "montant": 15.5, "statut": "pending"},
    {"id": 303, "montant": 40.0, "statut": "paid"},
]

EV_PAYMENTS = [
    {
        "id": 401,
        "vehicle_id": 5,
        "matricule": "99887-X-3",
        "charging_station": "EV-01",
        "energy_kwh": 18.4,
        "amount": 92.0,
        "status": "paid",
        "started_at": (datetime.now() - timedelta(hours=4)).isoformat(),
        "finished_at": (datetime.now() - timedelta(hours=3)).isoformat(),
        "payment_method": "card",
    },
]

ADMIN_NOTIFICATIONS = [
    {
        "id": 1,
        "title": "Alerte critique",
        "message": "Une alerte critique a été détectée sur le capteur RFID.",
        "category": "security",
        "level": "critical",
        "is_read": False,
        "created_at": (datetime.now() - timedelta(minutes=12)).isoformat(),
        "source": "capteur RFID",
        "related_route": "/admin/alerts",
    },
]

BLACKLIST_EVENTS = [
    {
        "id": 1,
        "vehicle_id": 4,
        "matricule": "44556-D-2",
        "event_type": "wrong_spot",
        "risk_level": "high",
        "description": "Véhicule détecté dans une zone réservée.",
        "detected_at": (datetime.now() - timedelta(minutes=40)).isoformat(),
        "assigned_spot": "P1-03",
        "actual_spot": "P0-04",
        "resolved": False,
    },
]

ASCENSEUR = {
    "id": 1,
    "statut": "Opérationnel",
    "niveauActuel": 1,
}

# =========================================================
# HELPERS
# =========================================================

def count_spots_by_status():
    total = len(PARKING_SPOTS)
    libres = sum(1 for s in PARKING_SPOTS if s["statut"].lower() == "libre")
    occupes = sum(1 for s in PARKING_SPOTS if s["statut"].lower() in ["occupée", "occupee"])
    reservees = sum(1 for s in PARKING_SPOTS if s["statut"].lower() in ["réservée", "reservee"])
    return {
        "total": total,
        "libres": libres,
        "occupes": occupes,
        "reservees": reservees,
    }


def build_dashboard_data():
    counts = count_spots_by_status()
    total_alertes = len([a for a in ALERTES if not a["resolue"]])
    alertes_critiques = len(
        [a for a in ALERTES if a["niveau"].lower() == "critique" and not a["resolue"]]
    )
    total_capteurs = len(CAPTEURS)
    total_capteurs_offline = len([c for c in CAPTEURS if c["statut"].lower() != "online"])
    total_paiements = len(PAIEMENTS) + len(PARKING_PAYMENTS) + len(EV_PAYMENTS)
    total_vehicules = len(VEHICULES)
    total_stationnements_actifs = len([s for s in STATIONNEMENTS if s["sortie"] is None])

    return {
        "total_places": counts["total"],
        "occupied_places": counts["occupes"],
        "free_places": counts["libres"],
        "reserved_places": counts["reservees"],
        "total_alertes": total_alertes,
        "critical_alertes": alertes_critiques,
        "total_capteurs": total_capteurs,
        "offline_capteurs": total_capteurs_offline,
        "total_paiements": total_paiements,
        "total_vehicules": total_vehicules,
        "active_stationnements": total_stationnements_actifs,
        "elevator_status": ASCENSEUR["statut"],
        "elevator_level": ASCENSEUR["niveauActuel"],
        "occupancy_rate": round((counts["occupes"] / counts["total"]) * 100, 2) if counts["total"] > 0 else 0.0,
    }


def get_level_from_spot_number(numero):
    if numero.startswith("P1-"):
        return 1
    if numero.startswith("P2-"):
        return 2
    return 0


def get_level_label(level):
    if level == 0:
        return "Rez-de-chaussée"
    return f"Étage {level}"


def get_parking_status_by_levels():
    levels = {}

    for spot in PARKING_SPOTS:
        numero = spot["numero"]
        level = get_level_from_spot_number(numero)

        if level not in levels:
            levels[level] = {
                "niveau": level,
                "libelle": get_level_label(level),
                "libres": 0,
                "occupes": 0,
                "total": 0,
                "type": "standard",
            }

        levels[level]["total"] += 1

        if spot["statut"].lower() == "libre":
            levels[level]["libres"] += 1
        elif spot["statut"].lower() in ["occupée", "occupee"]:
            levels[level]["occupes"] += 1

        if spot["type"] != "standard":
            levels[level]["type"] = spot["type"]

    return [levels[key] for key in sorted(levels.keys())]


def find_user_by_credentials(email, password):
    for user in USERS:
        if user["email"] == email and user["password"] == password:
            return user
    return None


def find_user_by_id(user_id):
    for user in USERS:
        if user["id"] == user_id:
            return user
    return None


def get_current_user_from_token():
    auth_header = request.headers.get("Authorization", "")

    if not auth_header.startswith("Bearer "):
        return None

    token = auth_header.replace("Bearer ", "").strip()

    if not token.startswith("fake_token_"):
        return None

    parts = token.split("_")
    if len(parts) < 4:
        return None

    try:
        user_id = int(parts[-1])
    except ValueError:
        return None

    return find_user_by_id(user_id)


def build_user_payload(user):
    return {
        "id": user["id"],
        "nom": user["nom"],
        "prenom": user.get("prenom", ""),
        "email": user["email"],
        "telephone": user.get("telephone", ""),
        "role": user["role"],
    }


def find_vehicle_by_id(vehicle_id):
    for vehicle in VEHICULES:
        if vehicle["id"] == vehicle_id:
            return vehicle
    return None


def find_spot_by_id(spot_id):
    for spot in PARKING_SPOTS:
        if spot["id"] == spot_id:
            return spot
    return None


def get_vehicle_alerts():
    return [
        a for a in ALERTES
        if (not a["resolue"]) and (
            "vehicule" in a["type"].lower()
            or "vehicle" in a["type"].lower()
            or "voiture" in a["type"].lower()
        )
    ]


def get_sensor_alerts():
    return [
        a for a in ALERTES
        if (not a["resolue"]) and (
            "capteur" in a["type"].lower()
            or "sensor" in a["type"].lower()
        )
    ]


def build_stats_overview():
    weekly_revenue = sum(p["montant"] for p in PAIEMENTS + PARKING_PAYMENTS) + sum(
        p["amount"] for p in EV_PAYMENTS
    )

    durations_hours = []
    for s in STATIONNEMENTS:
        entree = datetime.fromisoformat(s["entree"])
        sortie = datetime.fromisoformat(s["sortie"]) if s["sortie"] else datetime.now()
        duration = (sortie - entree).total_seconds() / 3600
        if duration >= 0:
            durations_hours.append(duration)

    avg_duration = round(sum(durations_hours) / len(durations_hours), 2) if durations_hours else 0.0

    weekly_traffic = [
        {"label": "Lun", "value": 18},
        {"label": "Mar", "value": 22},
        {"label": "Mer", "value": 20},
        {"label": "Jeu", "value": 25},
        {"label": "Ven", "value": 29},
        {"label": "Sam", "value": 16},
        {"label": "Dim", "value": 11},
    ]

    revenue_series = [
        {"label": "Lun", "value": 120.0},
        {"label": "Mar", "value": 145.5},
        {"label": "Mer", "value": 132.0},
        {"label": "Jeu", "value": 180.0},
        {"label": "Ven", "value": 210.0},
        {"label": "Sam", "value": 95.0},
        {"label": "Dim", "value": 76.0},
    ]

    weight_series = [
        {"label": "SUV", "average_weight": 1800.0},
        {"label": "Citadine", "average_weight": 1100.0},
        {"label": "Berline", "average_weight": 1450.0},
        {"label": "Utilitaire", "average_weight": 2200.0},
    ]

    return {
        "weekly_revenue": weekly_revenue,
        "average_daily_traffic": len(VEHICULES),
        "average_parking_duration_hours": avg_duration,
        "weekly_ev_charges": len(EV_PAYMENTS),
        "weekly_traffic": weekly_traffic,
        "revenue_series": revenue_series,
        "weight_series": weight_series,
    }

# =========================================================
# ROOT
# =========================================================

@app.route("/")
def accueil():
    return jsonify({
        "message": "Mon API Parking fonctionne !",
        "service": "Smart Parking API",
        "version": "2.1.0",
    })

# =========================================================
# AUTH
# =========================================================

@app.route("/api/auth/login", methods=["POST"])
def login():
    data = request.get_json(silent=True) or {}
    email = data.get("email", "").strip().lower()
    password = data.get("password", "")

    user = find_user_by_credentials(email, password)

    if not user:
        return jsonify({
            "success": False,
            "error": "Email ou mot de passe incorrect",
        }), 401

    return jsonify({
        "success": True,
        "token": f"fake_token_{user['role']}_{user['id']}",
        "user_id": user["id"],
        "user": build_user_payload(user),
    })


@app.route("/api/auth/register", methods=["POST"])
def register():
    data = request.get_json(silent=True) or {}

    email = data.get("email", "").strip().lower()
    nom = data.get("nom", "Utilisateur").strip()
    prenom = data.get("prenom", "").strip()
    telephone = data.get("telephone", "").strip()
    password = data.get("password", "").strip()

    if not email or not password:
        return jsonify({
            "success": False,
            "error": "Email et mot de passe requis",
        }), 400

    if any(u["email"].lower() == email for u in USERS):
        return jsonify({
            "success": False,
            "error": "Cet email existe déjà",
        }), 409

    new_id = max(u["id"] for u in USERS) + 1 if USERS else 1

    USERS.append({
        "id": new_id,
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "telephone": telephone,
        "password": password,
        "role": "client",
    })

    return jsonify({
        "success": True,
        "user_id": new_id,
        "message": "Inscription réussie",
    }), 201


@app.route("/api/auth/me", methods=["GET"])
def me():
    user = get_current_user_from_token()

    if not user:
        return jsonify({
            "success": False,
            "error": "Utilisateur non authentifié",
        }), 401

    return jsonify({
        "success": True,
        "user": build_user_payload(user),
    })


@app.route("/api/auth/logout", methods=["POST"])
def logout():
    return jsonify({
        "success": True,
        "message": "Déconnexion réussie",
    })

# =========================================================
# GENERAL PARKING
# =========================================================

@app.route("/api/parking/statut", methods=["GET"])
def statut():
    counts = count_spots_by_status()
    total = counts["total"]
    occupes = counts["occupes"]
    libres = counts["libres"]

    taux = (occupes / total * 100) if total > 0 else 0.0

    return jsonify({
        "places_libres": libres,
        "places_occupees": occupes,
        "total_places": total,
        "taux_occupation": round(taux, 2),
        "entrees_jour": 42,
        "ca_jour": 1250,
    })


@app.route("/api/parking/statut-par-niveau", methods=["GET"])
def get_statut_par_niveau():
    return jsonify(get_parking_status_by_levels())

# =========================================================
# ADMIN
# =========================================================

@app.route("/api/admin/dashboard", methods=["GET"])
def admin_dashboard():
    return jsonify(build_dashboard_data())


@app.route("/api/admin/alertes", methods=["GET"])
def admin_alertes():
    active_alertes = [a for a in ALERTES if not a["resolue"]]
    return jsonify({"alertes": active_alertes})


@app.route("/api/admin/alertes/vehicules", methods=["GET"])
def admin_vehicle_alertes():
    return jsonify({"alertes": get_vehicle_alerts()})


@app.route("/api/admin/alertes/capteurs", methods=["GET"])
def admin_sensor_alertes():
    return jsonify({"alertes": get_sensor_alerts()})


@app.route("/api/admin/alertes/<int:alerte_id>/resoudre", methods=["PUT"])
def admin_resolve_alerte(alerte_id):
    data = request.get_json(silent=True) or {}
    commentaire = data.get("commentaire", "")

    for alerte in ALERTES:
        if alerte["id"] == alerte_id:
            alerte["resolue"] = True
            alerte["commentaire"] = commentaire
            return jsonify({
                "success": True,
                "message": f"Alerte {alerte_id} résolue",
            })

    return jsonify({
        "success": False,
        "error": "Alerte introuvable",
    }), 404


@app.route("/api/admin/users", methods=["POST"])
def admin_create_user():
    current_user = get_current_user_from_token()

    if not current_user:
        return jsonify({
            "success": False,
            "error": "Authentification requise",
        }), 401

    if current_user["role"] != "admin":
        return jsonify({
            "success": False,
            "error": "Accès refusé",
        }), 403

    data = request.get_json(silent=True) or {}

    nom = data.get("nom", "").strip()
    prenom = data.get("prenom", "").strip()
    email = data.get("email", "").strip().lower()
    password = data.get("password", "admin123").strip()
    role = data.get("role", "admin").strip().lower()

    if not nom or not prenom or not email:
        return jsonify({
            "success": False,
            "error": "Nom, prénom et email sont requis",
        }), 400

    if any(u["email"].lower() == email for u in USERS):
        return jsonify({
            "success": False,
            "error": "Cet email existe déjà",
        }), 409

    new_id = max(u["id"] for u in USERS) + 1 if USERS else 1

    new_user = {
        "id": new_id,
        "nom": nom,
        "prenom": prenom,
        "email": email,
        "telephone": data.get("telephone", "").strip(),
        "password": password,
        "role": role if role in ["admin", "client"] else "admin",
    }

    USERS.append(new_user)

    return jsonify({
        "success": True,
        "message": "Administrateur créé avec succès",
        "user": build_user_payload(new_user),
    }), 201


@app.route("/api/admin/capteurs", methods=["GET"])
def admin_capteurs():
    return jsonify({"capteurs": CAPTEURS})


@app.route("/api/admin/vehicules", methods=["GET"])
def admin_vehicules():
    return jsonify({"vehicules": VEHICULES})


@app.route("/api/admin/parking", methods=["GET"])
def admin_parking():
    counts = count_spots_by_status()
    return jsonify(counts)


@app.route("/api/admin/parking/niveaux", methods=["GET"])
def admin_parking_levels():
    return jsonify({"niveaux": get_parking_status_by_levels()})


@app.route("/api/admin/parking/places", methods=["GET"])
def admin_parking_places():
    return jsonify({"places": PARKING_SPOTS})


@app.route("/api/admin/stationnements", methods=["GET"])
def admin_stationnements():
    return jsonify({"stationnements": STATIONNEMENTS})


@app.route("/api/admin/paiements", methods=["GET"])
def admin_paiements():
    return jsonify({"paiements": PAIEMENTS})


@app.route("/api/admin/paiements/parking", methods=["GET"])
def admin_parking_payments():
    return jsonify({"paiements": PARKING_PAYMENTS})


@app.route("/api/admin/paiements/ev", methods=["GET"])
def admin_ev_payments():
    return jsonify({"paiements": EV_PAYMENTS})


@app.route("/api/admin/ascenseur", methods=["GET"])
def admin_ascenseur():
    return jsonify({"ascenseur": ASCENSEUR})


@app.route("/api/admin/notifications", methods=["GET"])
def admin_notifications():
    return jsonify({"notifications": ADMIN_NOTIFICATIONS})


@app.route("/api/admin/notifications/<int:notification_id>/read", methods=["PUT"])
def mark_notification_as_read(notification_id):
    for notification in ADMIN_NOTIFICATIONS:
        if notification["id"] == notification_id:
            notification["is_read"] = True
            return jsonify({
                "success": True,
                "message": f"Notification {notification_id} marquée comme lue",
            })

    return jsonify({
        "success": False,
        "error": "Notification introuvable",
    }), 404


@app.route("/api/admin/notifications/read-all", methods=["PUT"])
def mark_all_notifications_as_read():
    for notification in ADMIN_NOTIFICATIONS:
        notification["is_read"] = True

    return jsonify({
        "success": True,
        "message": "Toutes les notifications ont été marquées comme lues",
    })


@app.route("/api/admin/blacklist", methods=["GET"])
def admin_blacklist():
    return jsonify({"events": BLACKLIST_EVENTS})


@app.route("/api/admin/stats/overview", methods=["GET"])
def admin_stats_overview():
    return jsonify(build_stats_overview())

# =========================================================
# CLIENT / VEHICULE / RESERVATION
# =========================================================

@app.route("/api/vehicules", methods=["GET"])
def get_vehicules():
    return jsonify({"vehicules": VEHICULES})


@app.route("/api/reservation", methods=["POST"])
def create_reservation():
    data = request.get_json(silent=True) or {}

    distance = data.get("distance", 0)
    temps_trajet = data.get("temps_trajet", 0)
    charge = data.get("charge_supplementaire", 0)
    plaque = data.get("plaque", "INCONNUE")
    modele = data.get("modele", "Véhicule")
    date_debut = data.get("date_debut", datetime.now().isoformat())
    date_fin = data.get("date_fin", (datetime.now() + timedelta(hours=2)).isoformat())

    free_spot = next(
        (spot for spot in PARKING_SPOTS if spot["statut"].lower() == "libre"),
        None
    )

    if free_spot is None:
        return jsonify({
            "success": False,
            "error": "Aucune place libre disponible",
        }), 409

    reservation_id = len(RESERVATIONS_HISTORY) + 1000
    free_spot["statut"] = "Réservée"

    RESERVATIONS_HISTORY.append({
        "id": reservation_id,
        "user_id": 1,
        "code_confirmation": f"RES{reservation_id}",
        "date_reservation": datetime.now().isoformat(),
        "date_debut": date_debut,
        "date_fin": date_fin,
        "plaque": plaque,
        "modele": modele,
        "charge": charge,
        "montant": 20.0,
        "statut": "confirmée",
        "emplacement": free_spot["numero"],
    })

    return jsonify({
        "success": True,
        "reservation_id": reservation_id,
        "message": "Réservation créée avec succès",
        "code_confirmation": f"RES{reservation_id}",
        "distance": distance,
        "temps_trajet": temps_trajet,
        "charge": charge,
        "place": {
            "id": free_spot["id"],
            "numero": free_spot["numero"],
            "statut": free_spot["statut"],
        },
        "heure_arrivee_estimee": (
            datetime.now() + timedelta(minutes=int(temps_trajet))
        ).strftime("%H:%M"),
    })


@app.route("/api/reservations/historique", methods=["GET"])
def reservation_history():
    return jsonify({
        "success": True,
        "reservations": RESERVATIONS_HISTORY,
    })


@app.route("/api/reservation/<int:reservation_id>/annuler", methods=["POST"])
def cancel_reservation(reservation_id):
    for reservation in RESERVATIONS_HISTORY:
        if reservation["id"] == reservation_id:
            reservation["statut"] = "annulée"
            return jsonify({
                "success": True,
                "message": "Réservation annulée avec succès",
            })

    return jsonify({
        "success": False,
        "message": "Réservation introuvable",
    }), 404


@app.route("/api/payment/process", methods=["POST"])
def process_payment():
    data = request.get_json(silent=True) or {}
    montant = data.get("montant", 0)

    return jsonify({
        "success": True,
        "transaction_id": f"PAY-{len(PAIEMENTS) + 1}",
        "message": "Paiement effectué avec succès",
        "montant": montant,
    })


@app.route("/api/stationnement/actif", methods=["GET"])
def get_stationnement_actif():
    actif = next((s for s in STATIONNEMENTS if s["sortie"] is None and s.get("user_id") == 1), None)

    if not actif:
        return jsonify({
            "has_active": False,
            "stationnement": None,
        })

    vehicle = find_vehicle_by_id(actif["vehicle_id"])
    spot = find_spot_by_id(actif["parking_spot_id"])
    numero = spot["numero"] if spot else "P0-00"
    niveau = get_level_from_spot_number(numero)

    return jsonify({
        "has_active": True,
        "stationnement": {
            "id": actif["id"],
            "vehicle_id": actif["vehicle_id"],
            "parking_spot_id": actif["parking_spot_id"],
            "entree": actif["entree"],
            "sortie": actif["sortie"],
            "plaque": vehicle["matricule"] if vehicle else None,
            "place_numero": numero,
            "niveau": niveau,
            "box": numero,
            "emplacement": f"Place {numero}",
            "date_entree": actif["entree"],
            "qr_code": f"PARKING:{vehicle['matricule']}:{actif['id']}" if vehicle else None,
            "rfid_ticket": f"RFID:{actif['id']}",
        }
    })


@app.route("/api/vehicule/<string:plaque>/localisation", methods=["GET"])
def localiser_vehicule(plaque):
    vehicule = next(
        (v for v in VEHICULES if v["matricule"].lower() == plaque.lower()),
        None
    )

    if not vehicule:
        return jsonify({
            "trouve": False,
            "message": f"Le véhicule {plaque} est introuvable",
        }), 404

    stationnement = next(
        (
            s for s in STATIONNEMENTS
            if s["vehicle_id"] == vehicule["id"] and s["sortie"] is None
        ),
        None
    )

    if not stationnement:
        return jsonify({
            "trouve": False,
            "message": f"Aucun stationnement actif pour {plaque}",
        }), 404

    spot = find_spot_by_id(stationnement["parking_spot_id"])
    numero = spot["numero"] if spot else None
    niveau = get_level_from_spot_number(numero) if numero else None

    return jsonify({
        "trouve": True,
        "vehicle_id": vehicule["id"],
        "matricule": vehicule["matricule"],
        "niveau": niveau,
        "place_id": spot["id"] if spot else None,
        "place": numero,
        "message": f"Votre véhicule {plaque} est à la place {numero}" if numero else "Position inconnue",
    })


if __name__ == "__main__":
    app.run(debug=True, port=5000)