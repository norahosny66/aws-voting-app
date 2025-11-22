FROM python:3.9

WORKDIR /app

RUN pip install --no-cache-dir Flask==2.3.3 redis==5.2.0 requests==2.32.0

# Create non-root user
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app

# Grant permission to bind port 80
RUN apt-get update && apt-get install -y libcap2-bin \
    && setcap 'cap_net_bind_service=+ep' $(which python3)

USER appuser

COPY --chown=appuser:appuser . .

# Healthcheck must still use port 80
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import socket; socket.create_connection(('localhost', 80), timeout=2)"

EXPOSE 80

CMD ["python", "app.py"]
