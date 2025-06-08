from fastapi import FastAPI, Security, HTTPException
from fastapi.security.api_key import APIKeyHeader
import logging
from datetime import datetime
import json
from pathlib import Path
import os
from models import HealthResponse

app = FastAPI()

# Basic logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# API Key configuration
API_KEY = os.environ.get("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY environment variable is not set")

API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

async def get_api_key(api_key_header: str = Security(api_key_header)):
    if api_key_header != API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid API Key"
        )
    return api_key_header

def load_products():
    """
    Load products from JSON file
    """
    try:
        json_path = Path(__file__).parent / "data" / "products.json"
        with open(json_path, 'r', encoding='utf-8') as file:
            return json.load(file)
    except Exception as e:
        logger.error(f"Error loading products: {e}")
        return {"products": []}

@app.get("/health", response_model=HealthResponse)
def health_check():
    """
    Health check endpoint
    """
    logger.info("Health check endpoint called")
    return HealthResponse(
        data={
            "status": "ok",
            "timestamp": datetime.now().isoformat()
        }
    )

@app.get("/api/products", dependencies=[Security(get_api_key)])
def get_products():
    """
    Returns list of products in JSON format
    """
    logger.info("Products endpoint called")
    return load_products()

@app.get("/api/products/{product_id}", dependencies=[Security(get_api_key)])
def get_product(product_id: int):
    """
    Returns a specific product by ID
    """
    logger.info(f"Product endpoint called for id {product_id}")
    data = load_products()
    for product in data.get("products", []):
        if product["id"] == product_id:
            return {"product": product}
    return {"error": "Product not found"} 