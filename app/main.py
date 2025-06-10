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

async def get_secret():
    secret_name = "fastapi/api_key"
    region_name = os.environ.get("AWS_REGION", "us-east-1")
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    get_secret_value_response = await asyncio.to_thread(client.get_secret_value, SecretId=secret_name)
    secret = get_secret_value_response['SecretString']
    return json.loads(secret)["API_KEY"]

API_KEY = None

if "PYTEST_CURRENT_TEST" in os.environ or "pytest" in sys.modules:
    # Si estamos corriendo tests, usa un API_KEY de test
    API_KEY = "test_api_key"
else:
    # Solo en ejecución normal, obtén el secreto de AWS
    API_KEY = asyncio.run(get_secret())

API_KEY_NAME = "X-API-Key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

async def get_api_key(api_key_header: str = Security(api_key_header)):
    if api_key_header != API_KEY:
        raise HTTPException(
            status_code=401,
            detail="Invalid API Key"
        )
    return api_key_header

async def load_products():
    """
    Load products from JSON file
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
    return {"message": "¡Welcome to my API FastAPI!"}

@app.get("/health", response_model=HealthResponse)
async def health_check():
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

@app.get("/api/products", response_model=ProductsResponse, dependencies=[Security(get_api_key)])
async def get_products():
    """
    Returns list of products in JSON format
    """
    logger.info("Products endpoint called")
    products_data = (await load_products()).get("products", [])
    products = [Product(**item) for item in products_data]
    return ProductsResponse(data=products)

@app.get("/api/products/{product_id}", dependencies=[Security(get_api_key)])
async def get_product(product_id: int):
    """
    Returns a specific product by ID
    """
    logger.info(f"Product endpoint called for id {product_id}")
    data = await load_products()
    for product in data.get("products", []):
        if product["id"] == product_id:
            return {"product": product}
    return {"error": "Product not found"}

