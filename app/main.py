from fastapi import FastAPI, Depends, HTTPException, status, Request
from fastapi.security import APIKeyHeader
import logging
from datetime import datetime
import json
from pathlib import Path
import os
import boto3
from models import HealthResponse, Product, ProductsResponse

app = FastAPI()

# Configuración de logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def get_secret():
    """Obtener API key desde AWS Secrets Manager"""
    try:
        secret_name = "fastapi/api_key5"
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
        logger.error(f"Error obteniendo el secreto: {e}")
        return None

# Configuración de API Key
API_KEY = get_secret()
if not API_KEY:
    raise RuntimeError("No se pudo obtener el API key desde Secrets Manager")

API_KEY_HEADER = APIKeyHeader(name="X-API-Key")

async def verify_api_key(request: Request, api_key: str = Depends(API_KEY_HEADER)):
    logger.info(f"HEADERS_DEBUG: {request.headers}")
    if api_key != API_KEY:
        logger.error(f"AUTH_FAIL: Clave recibida='{api_key}' vs Clave esperada='{API_KEY[:4]}...'.")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="API Key inválida"
        )
    return api_key

async def load_products():
    """Cargar productos desde el archivo JSON"""
    try:
        json_path = Path(__file__).parent / "data" / "products.json"
        with open(json_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        logger.error(f"Error loading products: {e}")
        return {"products": []}

@app.get("/health")
async def health_check():
    """Endpoint de health check"""
    return {"status": "ok", "timestamp": datetime.now().isoformat()}

@app.get("/api/products", response_model=ProductsResponse)
async def get_products(api_key: str = Depends(verify_api_key)):
    """Obtener lista de productos"""
    products_data = (await load_products()).get("products", [])
    products = [Product(**item) for item in products_data]
    return ProductsResponse(data=products)

@app.get("/api/products/{product_id}")
async def get_product(product_id: int, api_key: str = Depends(verify_api_key)):
    """Obtener un producto específico por ID"""
    data = await load_products()
    for product in data.get("products", []):
        if product["id"] == product_id:
            return {"product": product}
    raise HTTPException(status_code=404, detail="Producto no encontrado")

