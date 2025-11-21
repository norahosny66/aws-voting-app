# Multi-stage build for .NET worker
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder

WORKDIR /src

# Copy project files
COPY . .

# Build the application
RUN dotnet publish -c Release -o /app/publish

# Runtime stage
FROM mcr.microsoft.com/dotnet/runtime:6.0

WORKDIR /app

# Create non-root user (use UID 1002 to avoid conflicts)
RUN useradd -m -u 1002 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy built application from builder
COPY --from=builder --chown=appuser:appuser /app/publish .

# Health check (basic for .NET)
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD dotnet --version || exit 1

CMD ["dotnet", "Worker.dll"]
