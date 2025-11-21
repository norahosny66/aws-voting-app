FROM mcr.microsoft.com/dotnet/sdk:6.0 AS builder
WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /app/publish
FROM mcr.microsoft.com/dotnet/runtime:6.0
WORKDIR /app
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser
COPY --from=builder --chown=appuser:appuser /app/publish .
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD dotnet --version || exit 1
CMD ["dotnet", "Worker.dll"]
