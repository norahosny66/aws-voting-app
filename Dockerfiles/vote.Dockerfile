FROM python:3.9-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
COPY --chown=appuser:appuser . .
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import socket; socket.create_connection(('localhost', 80), timeout=2)"
EXPOSE 80
CMD ["python", "app.py"]
