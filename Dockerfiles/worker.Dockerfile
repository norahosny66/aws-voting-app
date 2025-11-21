# Multi-stage build for .NET 7 Worker
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS builder

WORKDIR /src

# Copy project files
COPY . .

# Build the application
RUN dotnet publish -c Release -o /app/publish

# Runtime stage (.NET 7)
FROM mcr.microsoft.com/dotnet/runtime:7.0

WORKDIR /app

# Create non-root user (use UID 1002)
RUN useradd -m -u 1002 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Copy built application from builder
COPY --from=builder --chown=appuser:appuser /app/publish .

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD dotnet --version || exit 1

CMD ["dotnet", "Worker.dll"]
