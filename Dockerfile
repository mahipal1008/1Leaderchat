FROM ghcr.io/danny-avila/librechat:latest

# Copy custom LibreChat configuration with correct ownership (node user)
COPY --chown=node:node librechat.yaml /app/librechat.yaml

# ── CRITICAL FIX: Patch memory agent timeout from 3s to 30s ──
# LibreChat hardcodes a 3-second timeout for the memory agent LLM call.
# AWS Bedrock cold starts take 2-8s, so memory always times out.
# This sed patch increases the timeout to 30 seconds.
RUN sed -i 's/timeoutMs = 3000/timeoutMs = 30000/g' /app/api/server/controllers/agents/client.js 2>/dev/null || true

# Render expects the app to listen on port 10000
ENV PORT=10000
ENV HOST=0.0.0.0

# Limit Node.js memory for Render standard plan (2GB total, ~1.5GB for Node)
ENV NODE_OPTIONS="--max-old-space-size=1536"

EXPOSE 10000
