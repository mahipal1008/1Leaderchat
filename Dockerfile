FROM ghcr.io/danny-avila/librechat:latest

# Copy custom LibreChat configuration with correct ownership (node user)
COPY --chown=node:node librechat.yaml /app/librechat.yaml

# ── CRITICAL FIX: Patch memory agent timeout from 3s to 30s ──
# LibreChat hardcodes a 3-second timeout for the memory agent LLM call.
# AWS Bedrock cold starts take 2-8s, so memory always times out.
# This sed patch increases the timeout to 30 seconds.
RUN sed -i 's/timeoutMs = 3000/timeoutMs = 30000/g' /app/api/server/controllers/agents/client.js 2>/dev/null || true

# ── Upgrade AWS SDK for Bedrock API Key support ──
# Bedrock API Keys (BedrockAPIKey-*) require recent SDK for proper SigV4 handling.
# Install latest SDK at top level AND remove any nested copies so all packages
# use the upgraded version via npm hoisting.
USER root
RUN cd /app && \
    npm install @aws-sdk/client-bedrock-runtime@latest --save && \
    find node_modules/@langchain -path '*/node_modules/@aws-sdk/client-bedrock-runtime' -type d -exec rm -rf {} + 2>/dev/null; \
    find node_modules/@librechat -path '*/node_modules/@aws-sdk/client-bedrock-runtime' -type d -exec rm -rf {} + 2>/dev/null; \
    echo "AWS SDK upgrade complete"
USER node

# Render expects the app to listen on port 10000
ENV PORT=10000
ENV HOST=0.0.0.0

# Limit Node.js memory for Render standard plan (2GB total, ~1.5GB for Node)
ENV NODE_OPTIONS="--max-old-space-size=1536"

EXPOSE 10000
