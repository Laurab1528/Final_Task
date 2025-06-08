from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

def test_get_data():
    response = client.get("/api/data")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "data" in data
    assert isinstance(data["data"], list) 