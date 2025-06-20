from fastapi import FastAPI, Depends, HTTPException, status, Request, Header
from fastapi.security import APIKeyHeader
import logging
from datetime import datetime
import json
from pathlib import Path
import os
import boto3
from models import HealthResponse, Product, ProductsResponse

app = FastAPI()

# Logging configuration
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_secret():
    """Get API key from AWS Secrets Manager or .env depending on the environment"""
    environment = os.getenv("ENVIRONMENT")
    logger.info(f"Detected environment: '{environment}'. Deciding API Key source.")

    if environment == "test":
        logger.info("Loading API key from environment variable for testing")
        api_key = os.getenv("API_KEY")
        if not api_key:
            logger.error("API_KEY not found in environment variables")
            return None
        return api_key
    
    logger.info("Loading API key from AWS Secrets Manager")
    try:
        secret_name = os.getenv("SECRET_NAME", "fastapi/api_key5")
        region_name = os.environ.get("AWS_REGION", "us-east-1")
        
        session = boto3.session.Session()
        client = session.client(
            service_name='secretsmanager',
            region_name=region_name
        )
        
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
        secret = json.loads(get_secret_value_response['SecretString'])
        return secret.get("api_key")
    except Exception as e:
        logger.error(f"Error getting secret from AWS Secrets Manager: {e}")
        return None

# API Key Configuration
API_KEY = get_secret()
if not API_KEY:
    raise RuntimeError("Could not get API key. Make sure it is configured in environment variables or Secrets Manager.")

async def verify_api_key(x_api_key: str | None = Header(default=None, alias="X-API-Key")):
    if x_api_key is None:
        logger.error("AUTH_FAIL: Missing X-API-Key header.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing API Key"
        )
    if x_api_key != API_KEY:
        logger.error(f"AUTH_FAIL: Received key='{x_api_key}' vs Expected key='{API_KEY[:4]}...'.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key"
        )
    return x_api_key

async def load_products():
    """Load products from the JSON file"""
    try:
        json_path = Path(__file__).parent / "data" / "products.json"
        with open(json_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Error loading products: {e}")
        return {"products": []}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

@app.get("/api/products", response_model=ProductsResponse)
async def get_products(api_key: str = Depends(verify_api_key)):
    """Get product list"""
    products_data = (await load_products()).get("products", [])
    products = [Product(**item) for item in products_data]
    return ProductsResponse(data=products)

@app.get("/api/products/{product_id}")
async def get_product(product_id: int, api_key: str = Depends(verify_api_key)):
    """Get a specific product by ID"""
    data = await load_products()
    for product in data.get("products", []):
        if product["id"] == product_id:
            return {"product": product}
    raise HTTPException(status_code=404, detail="Product not found")

