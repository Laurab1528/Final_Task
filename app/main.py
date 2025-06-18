from fastapi import FastAPI, Security, HTTPException
from fastapi.security.api_key import APIKeyHeader
import logging
from datetime import datetime
import json
from pathlib import Path
import os
from models import HealthResponse, Product, ProductsResponse
from dotenv import load_dotenv
import boto3
import asyncio
import sys

app = FastAPI()
load_dotenv() 

# Basic logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

API_KEY = os.environ.get("API_KEY")
ENV = os.environ.get("ENV", "local")

# Si estamos en test, forzamos el API_KEY de test
if "PYTEST_CURRENT_TEST" in os.environ or "pytest" in sys.modules:
    API_KEY = "test_api_key"

if not API_KEY:
    raise RuntimeError("API_KEY no está definida en las variables de entorno.")

API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

async def get_api_key(api_key_header: str = Security(api_key_header)):
    """
    Dependency to validate the API key from the request header.
    Raises HTTP 401 if the key is invalid.
    """
    if api_key_header != API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid API Key"
        )
    return api_key_header

async def load_products():
    """
    Load products from the local JSON file.
    Returns a dictionary with the products list.
    """
    try:
        json_path = Path(__file__).parent / "data" / "products.json"
        data = await asyncio.to_thread(json_path.read_text, encoding='utf-8')
        return json.loads(data)
    except Exception as e:
        logger.error(f"Error loading products: {e}")
        return {"products": []}

@app.get("/")
async def read_root():
    """
    Root endpoint. Returns a welcome message.
    """
    return {"message": "Welcome to my FastAPI!"}

@app.get("/health", response_model=HealthResponse)
async def health_check():
    """
    Health check endpoint. Returns API status and current timestamp.
    """
    logger.info("Health check endpoint called")
    return HealthResponse(
        data={
            "status": "ok",
            "timestamp": datetime.now().isoformat()
        }
    )

@app.get("/api/products", response_model=ProductsResponse, dependencies=[Security(get_api_key)])
async def get_products():
    """
    Returns a list of products in JSON format. Requires a valid API key.
    """
    logger.info("Products endpoint called")
    products_data = (await load_products()).get("products", [])
    products = [Product(**item) for item in products_data]
    return ProductsResponse(data=products)

@app.get("/api/products/{product_id}", dependencies=[Security(get_api_key)])
async def get_product(product_id: int):
    """
    Returns a specific product by its ID. Requires a valid API key.
    """
    logger.info(f"Product endpoint called for id {product_id}")
    data = await load_products()
    for product in data.get("products", []):
        if product["id"] == product_id:
            return {"product": product}
    return {"error": "Product not found"}

