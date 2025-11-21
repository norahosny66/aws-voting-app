FROM python:3.9-slim
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2-utils curl && rm -rf /var/lib/apt/lists/*
COPY make-data.py .
COPY generate-votes.sh .
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt && chmod +x generate-votes.sh
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
CMD ["bash", "-c", "python make-data.py && bash generate-votes.sh"]
