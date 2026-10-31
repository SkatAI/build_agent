# Key concepts: what we used, and why

A short guide to the ideas behind the workshop. It explains why each piece exists and when you would use it, not how to type the commands.

## 1. Model, harness, agent

- **The model** (also called a large language model, or LLM) is a program that takes text in and produces text out. It does nothing else: it cannot remember, browse, read files or act.
- **The harness** is the ordinary code around the model. It decides what text to send, keeps the history, runs tools, and shows the results. In the workshop, the harness is `app.py`.
- **An agent** is a model plus a harness that lets it act in a loop: the model asks for an action, the harness carries it out, sends back the result, and the model continues until it can answer.

Almost everything you saw in the workshop (memory, tools, files, search, skills) is the harness, not the model. ChatGPT, Claude or Mistral's Le Chat are a model plus a large harness.

## 2. Tokens, context window and memory

- Models read and write **tokens**, pieces of words. As a rule of thumb, 1 token ≈ 4 characters in English.
- The **context window** is everything sent to the model in one call: instructions, the conversation, files, search results. It has a maximum size, and the bigger it is, the slower and more expensive the call.
- The model is **stateless**. A chat "remembers" only because the harness resends the whole conversation every time (step 2). Reload the page and it is gone.
- **Long-term memory** is a file the harness reads and adds to the context (step 4). Saving everything makes the context grow fast, so real assistants save only selected facts, chosen by the model (step 8).

## 3. System prompt

The system prompt is the text the harness puts before the conversation: who the model is, how it should answer, what it must not do (`system.md`, Amandine the farmer). The user never sees it, but it shapes every answer.

Lessons from the workshop:
- **Examples work better than descriptions.** "Mix in French words" did little; one example sentence worked.
- **The same prompt gives different results with different models.** Llama is chattier, Qwen is plainer.
- **The harness can add text you never wrote.** Ollama's template for Llama tells the model to answer with a tool call whenever tools are available, which explains its unnecessary tool calls.

## 4. Tools and the agent loop

A **tool** is a function the harness offers the model, described in a few words: "get today's date", "read a file", "search the web". The model cannot run it. It can only write a request in an agreed format, and the harness decides whether and how to run it.

What can go wrong, and what we saw:
- the model calls the wrong tool, or a tool it does not need;
- it invents an argument, or writes the request as plain text, so nothing runs;
- it ignores the tool's result and answers from its own memory (the wrong Star Trek actor).

The harness is also where **safety** lives: the agent can only read files in `docs/`, and it can only write if you switch on "Allow file writes". A document the agent reads can contain instructions (prompt injection), so permissions matter more than good intentions.

## 5. MCP (Model Context Protocol)

MCP is a standard way to connect tools to any agent, a bit like USB for AI tools. Instead of writing a "fetch a web page" function, step 9 plugs in an existing **MCP server** that offers it. The same server works with Claude, ChatGPT, OpenCode or Cursor. Companies now publish MCP servers for their products (calendars, databases, CRMs), so one agent can use many services without custom code for each.

## 6. Skills

A **skill** is a written procedure in plain language, stored in a file (`skills/fact-check/SKILL.md`). The system prompt lists only the skill names and one-line descriptions. When a task matches, the agent loads the full instructions.

Why: you cannot put every procedure in the system prompt, since it would fill the context window. Skills let non-programmers teach an agent a method ("how we fact-check", "how we write a press summary") by writing a text file, not code.

## 7. Local models and cloud models

| | Local (Ollama) | Cloud (OpenRouter, ChatGPT, Claude…) |
|---|---|---|
| Where it runs | your computer, or your codespace | the provider's servers |
| Data | stays with you | sent to the provider |
| Cost | free once downloaded | paid per token |
| Quality | small models (3 billion parameters), many mistakes | large models, much more reliable |

**Ollama** is a free program that downloads open models and runs them on your machine. We used two: Qwen 2.5 (Alibaba) and Llama 3.2 (Meta). **Open models** have downloadable weights; anyone can run them. **OpenRouter** is a single account that gives access to many cloud models from different labs.

In the workshop, the agent you built runs on a local model, while **OpenCode**, which writes the code, uses a large cloud model. That contrast is the point: the same kind of harness, with a model about a hundred times larger.

## 8. OpenCode and AGENTS.md

**OpenCode** is a coding agent: an agent whose tools read and edit files and run commands. You describe what you want in plain language, and it writes the code. Claude Code, Codex and Cursor are similar tools.

**`AGENTS.md`** is a file of standing instructions for coding agents working in a project: who the code is for, what style to follow, what not to touch. It is the coding agent's system prompt, written by the project owner. Many coding agents read a file like this automatically.

## 9. GitHub in five minutes

- **Git** keeps the full history of a folder of files. **GitHub** is a website that hosts these folders online so people can share and work on them.
- A **repository** (repo) is one project folder with its history (here, `build_agent`).
- A **commit** is a saved snapshot with a short message ("add web search"). You can go back to any commit.
- **Push** sends your commits to GitHub. **Pull** gets other people's commits. **Clone** downloads a whole repository for the first time.
- A **branch** is a parallel version for trying things without touching the main version (`main`). The instructor tested the workshop on a `workshop` branch, then brought the good changes back to `main`.
- **Codespaces** is a computer in the cloud that GitHub creates from a repository, with everything installed. Each participant gets their own copy. Changes made in it stay there, and later changes to the repository do not reach it unless you pull them.

## 10. Keys, .env and .gitignore

- An **API key** is a password that lets a program use a paid service (OpenRouter, Tavily). Anyone who has it can spend your money.
- **`.env`** is a small file that holds those keys on your machine. The programs read it; it is never shared publicly.
- **`.gitignore`** lists the files git must never save or publish: `.env` (secrets), `memory.md` (personal data), and large generated folders.
- If a key ends up on GitHub, automated scanners find it within minutes. That is why keys go in `.env`, and `.env` goes in `.gitignore`.

## What to remember

1. A model only produces text. Everything an agent "does" is done by the harness around it.
2. The context window is the agent's working memory: everything has to fit in it, and everything in it costs time and money.
3. Most agent errors come from the model's choices (wrong tool, invented facts) or from what the harness gives it (truncated results, misleading messages). Read the trace before trusting the answer.
4. Tools, MCP and skills are all ways of giving the model more abilities. Permissions decide which ones it can actually use.
