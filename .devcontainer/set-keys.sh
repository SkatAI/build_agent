#!/usr/bin/env bash
# Saves the API keys given by the teacher, for this terminal and every new one.
# Run with:  source .devcontainer/set-keys.sh
read -rsp "Paste the OpenRouter key, then press Enter: " OPENROUTER_API_KEY; echo
read -rsp "Paste the Tavily key, then press Enter: " TAVILY_API_KEY; echo
export OPENROUTER_API_KEY TAVILY_API_KEY
sed -i '/OPENROUTER_API_KEY=\|TAVILY_API_KEY=/d' ~/.bashrc
echo "export OPENROUTER_API_KEY='$OPENROUTER_API_KEY'" >> ~/.bashrc
echo "export TAVILY_API_KEY='$TAVILY_API_KEY'" >> ~/.bashrc
echo "Saved: OpenRouter key ending in ...${OPENROUTER_API_KEY: -4}, Tavily key ending in ...${TAVILY_API_KEY: -4}"
