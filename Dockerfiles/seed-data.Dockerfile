FROM python:3.9-slim

WORKDIR /app

# Install dependencies (Apache Bench for load testing)
RUN apt-get update && apt-get install -y --no-install-recommends \
    apache2-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy seed data scripts
COPY make-data.py .
COPY generate-votes.sh .


# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt && \
    chmod +x generate-votes.sh

# Create non-root user (use UID 1003 to avoid conflicts)
RUN useradd -m -u 1003 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Run the seed data generation
CMD ["bash", "-c", "python make-data.py && bash generate-votes.sh"]
