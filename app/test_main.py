import os
from fastapi.testclient import TestClient
from main import app, API_KEY


os.environ['ENVIRONMENT'] = 'test'
os.environ['API_KEY'] = '123456789'


client = TestClient(app)

def test_health_check():
    """
    Test the health check endpoint. Should return status and timestamp.
    """
    response = client.get("/health")
    assert response.status_code == 200
    assert "status" in response.json()

def test_get_products_unauthorized():
    """
    Test the products endpoint without API key. Should return 401 Unauthorized.
    """
    response = client.get("/api/products")
    assert response.status_code == 401

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
    Should return the product.
    """
    response = client.get("/api/products/1", headers={"X-API-Key": API_KEY})
    assert response.status_code == 200
    assert "product" in response.json()

def test_get_product_not_found():
    """
    Test retrieving a non-existent product by ID with a valid API key.
    Should return a 404 error.
    """
    response = client.get("/api/products/999", headers={"X-API-Key": API_KEY})
    assert response.status_code == 404
    assert "detail" in response.json()

