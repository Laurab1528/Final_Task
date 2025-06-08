from typing import Generic, TypeVar, Optional, List
from pydantic import BaseModel
from datetime import datetime

T = TypeVar('T')

class BaseResponse(BaseModel, Generic[T]):
    """
    Base model for all API responses
    """
    status: str = "success"
    message: Optional[str] = None
    timestamp: datetime = datetime.now()
    data: Optional[T] = None

class HealthResponse(BaseResponse[dict]):
    """
    Model for health check response
    """
    pass

class Product(BaseModel):
    id: int
    name: str
    price: float
    # Agrega aquí más campos según tu products.json

class ProductsResponse(BaseResponse[List[Product]]):
    pass

