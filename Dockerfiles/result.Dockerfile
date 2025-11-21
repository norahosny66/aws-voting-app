FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force
RUN addgroup -g 1000 appuser && adduser -D -u 1000 -G appuser appuser && chown -R appuser:appuser /app
USER appuser
COPY --chown=appuser:appuser . .
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
EXPOSE 80
CMD ["node", "server.js"]
