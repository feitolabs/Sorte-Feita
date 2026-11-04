import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_health():
    response = client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_spin_wheel_api():
    payload = {
        "wheel": {
            "name": "O que comer hoje",
            "options": [
                {"label": "Pizza", "weight": 1.0, "active": True},
                {"label": "Hambúrguer", "weight": 1.0, "active": True},
                {"label": "Salada", "weight": 1.0, "active": True}
            ]
        }
    }
    response = client.post("/api/v1/wheel/spin", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["winner_label"] in ["Pizza", "Hambúrguer", "Salada"]
    assert data["total_active_options"] == 3


def test_draw_names_api():
    payload = {
        "title": "Sorteio do Livro",
        "participants": ["Alice", "Bob", "Charlie", "David"],
        "winners_count": 2,
        "alternates_count": 1,
        "allow_duplicates": False
    }
    response = client.post("/api/v1/draws/names", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["winners"]) == 2
    assert len(data["alternates"]) == 1


def test_teams_api():
    payload = {
        "participants": ["Ana", "Bruno", "Carla", "Diego", "Eduarda", "Felipe"],
        "mode": "teams_count",
        "target_count": 2,
        "pick_captains": True
    }
    response = client.post("/api/v1/teams/generate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert len(data["teams"]) == 2
    assert sum(len(t["members"]) for t in data["teams"]) == 6
