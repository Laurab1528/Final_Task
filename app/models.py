from typing import Generic, TypeVar, Optional, List
from pydantic import BaseModel
from datetime import datetime

T = TypeVar('T')

class BaseResponse(BaseModel, Generic[T]):
    """
    Base model for all API responses.
    Includes status, optional message, timestamp, and generic data.
    """
    status: str = "success"
    message: Optional[str] = None
    timestamp: datetime = datetime.now()
    data: Optional[T] = None

class HealthResponse(BaseResponse[dict]):
    """
    Model for health check response.
    Inherits from BaseResponse with a dictionary as data.
    """
    pass

class Product(BaseModel):
    """
    Model representing a product.
    Fields should match the structure of products.json.
    """
    id: int
    name: str
    price: float
    # Add more fields here according to your products.json structure
    # Example: description: str, category: str, stock: int

class ProductsResponse(BaseResponse[List[Product]]):
    """
    Model for a response containing a list of products.
    Inherits from BaseResponse with a list of Product as data.
    """
    pass

