#!/usr/bin/env bash
# Start the Ollama server in the background (if it is not already running) and wait until it answers.
if ! curl -s http://localhost:11434 > /dev/null; then
  setsid nohup ollama serve > /tmp/ollama.log 2>&1 < /dev/null &
fi
for _ in $(seq 1 30); do
  curl -s http://localhost:11434 > /dev/null && echo "Ollama is running" && exit 0
  sleep 1
done
echo "Ollama did not start; see /tmp/ollama.log" && exit 1
