from fastapi.testclient import TestClient
from main import app
import os

client = TestClient(app)
API_KEY = "test_api_key"


def test_root():
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()["data"]

def test_get_products_unauthorized():
    response = client.get("/api/products")
    assert response.status_code == 401

def test_get_products_authorized():
    response = client.get("/api/products", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    data = response.json()
    assert "data" in data
    assert isinstance(data["data"], list)

def test_get_product_by_id():
    response = client.get("/api/products/1", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    assert "product" in response.json() or "error" in response.json()

def test_get_product_not_found():
    response = client.get("/api/products/999", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    assert "error" in response.json()

def test_get_data():
    response = client.get("/api/data")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "data" in data
    assert isinstance(data["data"], list) 