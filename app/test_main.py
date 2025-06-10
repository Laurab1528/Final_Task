from fastapi.testclient import TestClient
from main import app
import os

client = TestClient(app)
API_KEY = "test_api_key"


def test_root():
    """
    Test the root endpoint. Should return a welcome message.
    """
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()

def test_health_check():
    """
    Test the health check endpoint. Should return status and timestamp.
    """
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()["data"]

def test_get_products_unauthorized():
    """
    Test the products endpoint without API key. Should return 403 Forbidden.
    """
    response = client.get("/api/products")
    assert response.status_code == 403

def test_get_products_authorized():
    """
    Test the products endpoint with a valid API key. Should return a list of products.
    """
    response = client.get("/api/products", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    data = response.json()
    assert "data" in data
    assert isinstance(data["data"], list)

def test_get_product_by_id():
    """
    Test retrieving a product by ID with a valid API key.
    Should return the product or an error if not found.
    """
    response = client.get("/api/products/1", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    assert "product" in response.json() or "error" in response.json()

def test_get_product_not_found():
    """
    Test retrieving a non-existent product by ID with a valid API key.
    Should return an error message.
    """
    response = client.get("/api/products/999", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    assert "error" in response.json()

