# Build an AI agent, step by step

We build a small AI agent around a local model (llama3.2, running with Ollama), adding one capability at a time: memory, tools, files, web search, MCP, skills. The code is written live by OpenCode, a coding agent.

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/SkatAI/build_agent)

## Before class

Create a free account on [github.com](https://github.com/signup). Nothing else to install: everything runs in your browser.

## Start

1. Click **Open in GitHub Codespaces** above, then **Create codespace**. Wait until the terminal at the bottom says `Setup complete` (a few minutes the first time).
2. Check the model works: type `ollama run llama3.2`, ask it something, then type `/bye`.
3. Add the two keys your teacher gives you. Type this, then paste each key when asked (the key stays hidden while you paste):
   ```
   source .devcontainer/set-keys.sh
   ```
4. Start OpenCode: type `opencode`. The provider (OpenRouter) and the model are already set in `opencode.json`.

## Follow along

The prompts for each step are in [prompts.md](prompts.md). Paste a prompt into OpenCode, then run the agent in a second terminal:

```
uv run agent.py
```

| Step | Adds | What it shows |
|---|---|---|
| 1 | Chat loop | The model remembers nothing |
| 2 | Conversation history | "Memory" in a chat is the history being resent |
| 3 | System prompt (`system.md`) | The harness sets the model's behaviour |
| 4 | `memory.md` | Memory across sessions is a file |
| 5 | First tool (date) | The agent loop: the model asks, the harness acts |
| 6 | File tools (`docs/`) | Access limits and asking before writing |
| 7 | Web search (Tavily) | Current information and sources |
| 8 | `remember` tool | The model decides what to remember |
| 9 | MCP server (fetch) | Ready-made tools over a standard protocol |
| 10 | Skills (`skills/`) | Instructions loaded only when needed |
| 11 | `--model` option | Same harness, different model |

## Lost? Jump to any step

Every step has a working version. To load it (this replaces your files):

```
git checkout -f step-5
```

Go back to the start with `git checkout -f main`.

## After class

Stop your codespace to save your free hours: [github.com/codespaces](https://github.com/codespaces) → `...` → **Stop codespace**.

## Troubleshooting

- `Connection refused` or `Failed to connect to Ollama`: run `bash .devcontainer/start-ollama.sh`.
- The answer is slow: the model runs on a CPU, without a GPU. Wait a few seconds.
- The agent invents an answer instead of using a tool: llama3.2 is a small model. Compare with `uv run agent.py --model qwen2.5:3b` (step 11; run `ollama pull qwen2.5:3b` first).
