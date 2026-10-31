# Build an AI agent workshop, step by step

We build a small AI agent around a local model (llama3.2, running with [Ollama](https://ollama.com)), adding one capability at a time: memory, tools, files, web search, MCP, skills. 

You talk to the agent in a web page. The code is written live by [OpenCode](https://opencode.ai), an opensource coding agent.

You can use your local environment if you are confortable with the terminal or work on github Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/SkatAI/build_agent)

## Before the workshop

Create a free account on [github.com](https://github.com/signup). Nothing else to install: everything runs in your browser.

## Start

1. Click **Open in GitHub Codespaces** above, then **Create codespace**. Wait until the code editor appears.
2. The agent's web page opens in a panel ("My agent: nothing here yet"). If it doesn't, open the **PORTS** tab at the bottom, find port 8501 ("Agent") and click the globe icon.
3. Add the two keys your instructor gives you. In the terminal at the bottom, type this, then paste each key when asked (the key stays hidden while you paste):
   ```
   source .devcontainer/set-keys.sh
   ```
4. Start OpenCode: type `opencode` in the terminal. The provider (OpenRouter) and the model are already set in `opencode.json`.

## Follow along

The prompts for each step are in [prompts.md](prompts.md). Paste a prompt into OpenCode. When it saves `app.py`, the web page updates by itself: talk to your agent there.

| Step | Adds | What it shows |
|---|---|---|
| 1 | Chat page | The model remembers nothing |
| 2 | Conversation history | "Memory" in a chat is the history being resent |
| 3 | System prompt (`system.md`) | The harness sets the model's behaviour |
| 4 | `memory.md` | Memory across sessions is a file |
| 5 | First tool (date) | The agent loop: the model asks, the harness acts |
| 6 | File tools (`docs/`) | Access limits and permission to write |
| 7 | Web search (Tavily) | Current information and sources |
| 8 | `remember` tool | The model decides what to remember |
| 9 | MCP server (fetch) | Ready-made tools over a standard protocol |
| 10 | Skills (`skills/`) | Instructions loaded only when needed |
| 11 | Model choice | Same harness, different model |

Grey `[harness]` lines and "Tool result" boxes show what the program around the model does. The sidebar shows what is sent to the model.

## Lost? Jump to any step

Every step has a working version. To load it (this replaces your files), type in a terminal:

```
git checkout -f step-5
```

The web page updates by itself. Go back to the start with `git checkout -f main`.

## After class

Stop your codespace to save your free hours: [github.com/codespaces](https://github.com/codespaces) → `...` → **Stop codespace**.

## Troubleshooting

- The web page is blank or says "connection refused": run `bash .devcontainer/start-app.sh`.
- The page shows an error about Ollama: run `bash .devcontainer/start-ollama.sh`.
- The answer is slow: the model runs on a CPU, without a GPU. Wait a few seconds.
- The agent invents an answer instead of using a tool: llama3.2 is a small model. In step 11, run `ollama pull qwen2.5:3b` and pick it in the sidebar.
