FROM python:3.9-slim

WORKDIR /app

RUN pip install --no-cache-dir Flask==2.3.3 redis==5.2.0 requests==2.32.0

# Create non-root user (use different UID to avoid conflicts)
RUN useradd -m -u 1001 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import socket; socket.create_connection(('localhost', 8080), timeout=2)"

EXPOSE 8080

CMD ["python", "app.py"]
