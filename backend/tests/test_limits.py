from fastapi.testclient import TestClient
from app.main import app
from app.services.storage_service import MAX_ACTIVITIES, storage_service
from app.models.schemas import HistoryItem

client = TestClient(app)
B = "/api/v1"


def test_number_span_too_large_is_rejected_fast():
    r = client.post(f"{B}/draws/numbers", json={"min_val": 0, "max_val": 10**12, "count": 3})
    assert r.status_code == 422


def test_number_count_limit():
    r = client.post(f"{B}/draws/numbers", json={"min_val": 0, "max_val": 10, "count": 10**7, "allow_repeat": True})
    assert r.status_code == 422


def test_participants_limit():
    r = client.post(f"{B}/draws/names", json={"participants": ["a"] * 5001, "winners_count": 1})
    assert r.status_code == 422


def test_name_too_long():
    r = client.post(f"{B}/draws/names", json={"participants": ["x" * 201], "winners_count": 1})
    assert r.status_code == 422


def test_duplicates_are_case_insensitive():
    r = client.post(f"{B}/draws/names", json={"participants": ["Ana", "ana", "ANA", "Bia"], "winners_count": 2})
    assert r.status_code == 200
    assert r.json()["total_eligible"] == 2
    assert r.json()["duplicates_removed_count"] == 2


def test_history_is_capped():
    for i in range(MAX_ACTIVITIES + 5):
        storage_service.save_activity(HistoryItem(type="decision", title=str(i), config_snapshot={}, result="x"))
    assert len(storage_service.list_activities()) == MAX_ACTIVITIES


def test_cors_blocks_unknown_origin():
    r = client.options(f"{B}/wheel/spin", headers={"Origin": "http://evil.example", "Access-Control-Request-Method": "POST"})
    assert r.headers.get("access-control-allow-origin") != "http://evil.example"
    assert r.headers.get("access-control-allow-origin") != "*"
