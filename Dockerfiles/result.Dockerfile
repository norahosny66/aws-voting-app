FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install Python and pip
RUN apk add --no-cache python3 py3-pip bash

# Create a Python virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy Node package files and install dependencies
COPY package*.json ./
RUN npm install --omit=dev && npm cache clean --force

# Install Python packages in the venv
RUN pip install --no-cache-dir Flask==2.3.3 redis==5.2.0 requests==2.32.0

# Create non-root user and set ownership
RUN addgroup -g 1001 appuser && \
    adduser -D -u 1001 -G appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy application code
COPY --chown=appuser:appuser . .

# Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8081/ || exit 1

EXPOSE 8081

CMD ["node", "server.js"]
