# Building a local agent: OpenCode prompts

One prompt per step, each adding one capability to a single `agent.py` that runs on llama3.2 through Ollama. OpenCode (with a cloud model) writes the code; the agent itself runs locally, except web search in step 7.

## Setup

1. Open the codespace (see README). OpenCode reads `AGENTS.md` automatically: it holds the rules for every step.
2. Paste one prompt per step into OpenCode. Run the agent in a second terminal with `uv run agent.py`.
3. If a step goes wrong, `git checkout -f step-N` loads the tested version of that step.

llama3.2 (3B) handles tools unevenly: it sometimes calls a tool for a question that doesn't need one, or writes a tool call as text instead of making it. These failures are worth showing; step 11 compares another model.

## Part 1: Memory

### Step 1: Stateless chat

The model is a function: text in, text out. It remembers nothing.

```text
Create agent.py: a terminal chat loop. Read the user's message, send ONLY that message to the model, print the reply. Keep no history between turns. Type "quit" to exit.
```

Demo: "My name is Alexis." then "What is my name?". It doesn't know. Contrast with `ollama run llama3.2`, which does: the memory there comes from the chat program, not the model.

### Step 2: Conversation history

In-session memory is the harness resending the whole conversation every turn.

```text
Keep the conversation history: store every user message and model reply in a messages list, and send the full list on each turn. After each reply, print with [harness] how many messages were sent and their approximate size in tokens (total characters divided by 4).
```

Demo: the name question now works. Watch the size grow each turn: that is the context window filling up. Quit and restart: everything is gone.

### Step 3: System prompt

The harness decides who the model is before the user says anything.

```text
Load a system prompt from system.md and put it first in the messages list. Create system.md with: "You are a research assistant for Sciences Po students. Answer in 3 sentences or fewer. Say when you don't know."
```

Demo: ask a question, then add "Answer only in French." to system.md and restart.

### Step 4: Persistent memory

Memory across sessions is a file the harness reads and writes.

```text
Add memory that survives restarts. When the user types "quit", ask the model to list the lasting facts about the user as bullet points and save them to memory.md. At startup, read memory.md and add its content to the system prompt. Print [harness] lines when memory is loaded and saved.
```

Demo: "Hi, I'm Alexis, I teach at Sciences Po and I prefer short answers.", quit, restart, "What do you know about me?". Open memory.md: plain text anyone can read or edit.

## Part 2: Tools

### Step 5: First tool and the agent loop

The model can't act; it can only ask. The harness runs the function and sends back the result. This loop is what makes it an agent.

```text
Add tool calling. Write a Python function get_current_datetime() with the docstring "Get today's date and the current time. Use only when the user asks about the date or time." and pass it to ollama.chat as a tool. Implement the agent loop: if the reply contains tool calls, run each function, append the result as a "tool" message, and call the model again; repeat until the model replies with plain text. If a tool fails, send the error back to the model as text. Print each tool call and its result with [harness].
Add to system.md: "You have tools, but most questions do not need them. If no tool clearly matches the question, answer directly from your own knowledge without calling any tool. When a tool returns a result, trust it and use it in your answer."
```

Demo: before this step, ask "What is today's date?" (it guesses or refuses). After, ask again and point at the [harness] line. Then ask "What is the capital of Australia?": llama3.2 often calls the date tool anyway.

### Step 6: Local files

Tools give the agent reach; the harness decides how far.

```text
Add three file tools, all restricted to the docs/ folder (refuse any path outside it):
- list_files() lists the files in docs/
- read_file(name) returns a file's text
- write_file(name, content) writes a file, but first shows the user the file name and asks "Allow? (y/n)" in the terminal; on "n", return "The user refused." to the model.
```

`docs/` already holds two sample files that contradict each other.

Demo: "Which files do I have?", then "Do the press release and the interview notes agree on the budget?", then "Save a two-line summary of the contradiction to summary.md" and answer y.
Prompt injection: `cp extras/injection.txt docs/minutes.txt`, then "Summarize minutes.txt". The agent obeys the hidden instruction and tries to write hacked.txt; the y/n check stops it.

### Step 7: Web search

The model's knowledge stops at its training date; search brings in current sources.

```text
Add a web_search(query) tool using the tavily-python library. Read the key from the TAVILY_API_KEY environment variable; if it is missing, return "Web search is unavailable: TAVILY_API_KEY is not set." Return the top 3 results as title, URL and the first 300 characters. Add to system.md: "When you use web search, cite the URLs of your sources."
```

Demo: ask about something from this week. Compare with the step-6 version (`git checkout -f step-6`).

### Step 8: Memory as a tool

Instead of the harness saving at the end, the model decides what to remember, and when.

```text
Replace the end-of-session memory save with a remember(fact) tool that appends one line to memory.md. Keep loading memory.md at startup. Add to system.md: "When the user shares a lasting fact about themselves (name, job, preferences), call remember."
```

Demo: "Hi, I'm Alexis and I'm vegetarian." and watch the tool call. Quit, restart, "Suggest a dinner for me tonight." Discuss: what should an agent be allowed to remember, and who checks?

## Part 3: Standard extensions

### Step 9: MCP

Instead of writing each tool, plug in a server that offers ready-made ones over a standard protocol.

```text
Connect the agent to an MCP server. Use the official mcp Python SDK (version 2 or later: tool schemas are in tool.input_schema) to start `uvx mcp-server-fetch` over stdio, list its tools, convert them to Ollama tool definitions, and route calls for those tools to the MCP session. Before calling an MCP tool, drop arguments whose value is None. Keep the existing Python tools. At startup, print with [harness] the tools discovered from the MCP server. Shorten tool results to 300 characters in the [harness] lines.
```

Demo: "Fetch https://www.sciencespo.fr and tell me what is on the front page." No fetch code was written in agent.py: the same server works in Claude, OpenCode or Cursor.

### Step 10: Skills

A skill is a written procedure the agent loads only when it needs it. The system prompt holds just the index.

```text
Add skills. Each skill is a folder in skills/ containing a SKILL.md that starts with a header between --- lines, giving a name and a one-line description. At startup, add only the names and descriptions to the system prompt. Add a load_skill(name) tool that returns the full SKILL.md. Create skills/fact-check/SKILL.md: restate the claim, find two independent sources with web_search, give one line per source with its URL, then a verdict (TRUE, FALSE or UNVERIFIED). Never invent sources.
```

Demo: "Fact-check this claim: France is the most visited country in the world." Watch load_skill, then web_search. Then write a second skill live, in plain English, with no code.

### Step 11: Same harness, different model

The harness stays; the model is a swappable part.

```text
Make the model configurable from the command line: `uv run agent.py --model <name>`, defaulting to llama3.2. Print the model name at startup.
```

Demo: `ollama pull qwen2.5:3b`, then run the same questions with both models and compare the [harness] lines: unneeded tool calls, wrong arguments, invented answers. Close by noting that OpenCode, which wrote all of this, is the same kind of harness around a much larger model.
