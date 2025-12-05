# Multi-stage Dockerfile for Python application
# Optimized for Google Cloud Run deployment
#
# Build: docker build -t myapp .
# Run:   docker run -p 8080:8080 myapp

# =============================================================================
# Stage 1: Build stage with UV for fast dependency installation
# =============================================================================
FROM python:3.13-slim AS builder

# Install UV package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Set working directory
WORKDIR /app

# Copy dependency files first (for better caching)
COPY python/pyproject.toml python/uv.lock* ./

# Create virtual environment and install dependencies
RUN uv venv /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install production dependencies only
RUN uv pip install --no-cache -r pyproject.toml 2>/dev/null || \
    uv pip install --no-cache . 2>/dev/null || \
    echo "No dependencies to install"

# Copy application code
COPY python/src ./src

# =============================================================================
# Stage 2: Production runtime image
# =============================================================================
FROM python:3.13-slim AS runtime

# Security: Run as non-root user
RUN groupadd --gid 1000 appgroup && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home appuser

# Set working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY --from=builder /app/src ./src

# Set environment variables
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Cloud Run uses PORT environment variable
ENV PORT=8080

# Switch to non-root user
USER appuser

# Expose the port
EXPOSE 8080

# Health check (optional but recommended)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8080/health')" || exit 1

# Run the application
# Adjust this command based on your application framework
# Examples:
#   FastAPI:  CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8080"]
#   Flask:    CMD ["gunicorn", "--bind", "0.0.0.0:8080", "src.main:app"]
#   Generic:  CMD ["python", "-m", "src.main"]

CMD ["python", "-m", "src.main"]
