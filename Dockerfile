FROM ghcr.io/danny-avila/librechat:latest

# Copy custom LibreChat configuration
COPY librechat.yaml /app/librechat.yaml

# LibreChat listens on PORT env var (default 3080, Render uses 10000)
ENV HOST=0.0.0.0
EXPOSE 3080
