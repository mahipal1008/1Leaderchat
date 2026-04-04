FROM ghcr.io/danny-avila/librechat:latest

# Copy custom LibreChat configuration with correct ownership (node user)
COPY --chown=node:node librechat.yaml /app/librechat.yaml

# ── CRITICAL FIX: Patch memory agent timeout from 3s to 30s ──
# LibreChat hardcodes a 3-second timeout for the memory agent LLM call.
# AWS Bedrock cold starts take 2-8 seconds, so memory ALWAYS times out.
# This patch increases the timeout to 30 seconds so Bedrock has time to respond.
# File: api/server/controllers/agents/client.js
# Method: awaitMemoryWithTimeout(memoryPromise, timeoutMs = 3000)
USER root
RUN find /app -name "client.js" -path "*/controllers/agents/*" -exec \
    sed -i 's/timeoutMs = 3000/timeoutMs = 30000/g' {} \; && \
    echo "Patched memory timeout to 30s"
USER node

# Render expects the app to listen on port 10000
ENV PORT=10000
ENV HOST=0.0.0.0

# Limit Node.js memory for Render standard plan (2GB total, ~1.5GB for Node)
ENV NODE_OPTIONS="--max-old-space-size=1536"

EXPOSE 10000
