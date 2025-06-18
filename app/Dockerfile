FROM python:3.10-slim

# Metadatos
LABEL maintainer="Your Name laurab1528@hotmail.com"
LABEL description="FastAPI application for EKS deployment"

# Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8080

# Crear usuario no root
RUN adduser --system --group app

# Establecer directorio de trabajo
WORKDIR /app

# Copiar toda la app
COPY app/ /app

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Cambiar permisos
RUN chown -R app:app /app

# Cambiar a usuario no root
USER app

# Exponer puerto
EXPOSE 8080

# Healthcheck para Kubernetes
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:8080/health || exit 1

# Comando para ejecutar la app
CMD ["python", "-m", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]

