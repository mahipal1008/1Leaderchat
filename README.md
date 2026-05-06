# 1Leaderchat

Custom [LibreChat](https://github.com/danny-avila/LibreChat) deployment configured for AWS Bedrock and hosted on Render.

## Overview

This repository contains the deployment configuration for a self-hosted LibreChat instance with the following customizations:

- **AWS Bedrock** as the primary LLM provider (using long-term Bedrock API keys)
- **Memory agent timeout patch** — increases the hardcoded 3s timeout to 30s to accommodate Bedrock cold starts (2–8s)
- **Upgraded AWS SDK** (`@aws-sdk/client-bedrock-runtime@latest`) for proper SigV4 handling of Bedrock API keys
- **Render-ready** — listens on port `10000` with memory limits tuned for the Render Standard plan

## Repository Structure

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the customized LibreChat image (patches + SDK upgrade) |
| `librechat.yaml` | LibreChat application configuration (endpoints, models, agents) |
| `envvars.json` | Environment variable definitions for deployment |
| `bedrock-long-term-api-key.csv` | Bedrock API key reference (do not commit real secrets) |

## Deployment

The image is built from `ghcr.io/danny-avila/librechat:latest` and deployed to Render.

```bash
docker build -t 1leaderchat .
docker run -p 10000:10000 --env-file .env 1leaderchat
```

### Environment

- `PORT=10000`
- `HOST=0.0.0.0`
- `NODE_OPTIONS=--max-old-space-size=1536`

Additional Bedrock and LibreChat-specific variables are defined in `.env` / `envvars.json`.

## Key Patches

1. **Memory agent timeout** — patched in `/app/api/server/controllers/agents/client.js`:
   ```
   timeoutMs = 3000  →  timeoutMs = 30000
   ```
2. **AWS SDK hoisting** — removes nested copies of `@aws-sdk/client-bedrock-runtime` under `@langchain` and `@librechat` so all packages use the upgraded top-level version.

## License

Based on LibreChat (MIT). Configuration in this repository is provided as-is.
