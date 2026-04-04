FROM ghcr.io/danny-avila/librechat:latest

# Copy custom LibreChat configuration with correct ownership (node user)
COPY --chown=node:node librechat.yaml /app/librechat.yaml

# Render expects the app to listen on port 10000
ENV PORT=10000
ENV HOST=0.0.0.0

# Limit Node.js memory for Render standard plan (2GB total, ~1.5GB for Node)
ENV NODE_OPTIONS="--max-old-space-size=1536"

EXPOSE 10000
