#!/usr/bin/env bash
# One-time setup of the codespace: Ollama + llama3.2, uv, OpenCode.
set -euo pipefail

echo "==> Installing zstd (needed by the Ollama installer)"
sudo apt-get update -qq && sudo apt-get install -y -qq zstd

echo "==> Installing Ollama"
curl -fsSL https://ollama.com/install.sh | sh

echo "==> Installing uv (it also installs Python when needed)"
curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"

echo "==> Installing OpenCode"
curl -fsSL https://opencode.ai/install | bash

echo "==> Downloading llama3.2 (about 2 GB)"
bash .devcontainer/start-ollama.sh
ollama pull llama3.2

echo "==> Pre-downloading the Python packages and the MCP fetch server used by the agent"
uv run --with ollama --with tavily-python --with "mcp>=2" python -c "print('packages ready')"
uv tool install mcp-server-fetch

echo "==> Setup complete"
