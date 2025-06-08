# Build stage
FROM python:3.10-slim as builder

# Set working directory
WORKDIR /app

# Copy only necessary files for installing dependencies
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Final stage
FROM python:3.10-slim

# Container metadata
LABEL maintainer="Your Name <your.email@example.com>"
LABEL description="FastAPI application for EKS deployment"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=80

# Create non-root user
RUN adduser --system --group app

WORKDIR /app

# Copy only necessary files from builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages/ /usr/local/lib/python3.10/site-packages/
COPY main.py .
COPY data/ data/

# Change files ownership to non-root user
RUN chown -R app:app /app

# Switch to non-root user
USER app

# Expose port
EXPOSE 80

# Health check for Kubernetes
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:80/health || exit 1

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"] 