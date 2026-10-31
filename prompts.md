# Building a local agent: OpenCode prompts

One prompt per step, each adding one capability to `app.py`: a web page where you talk to an agent that runs on llama3.2 through Ollama. OpenCode (with a cloud model) writes the code; the agent itself runs locally, except web search in step 7.

## Setup

1. Open the codespace, or run it on your computer (see README). The agent's page runs on port 8804 and reloads by itself each time `app.py` is saved. OpenCode reads `AGENTS.md` automatically: it holds the rules for every step.
2. Paste one prompt per step into OpenCode, then talk to the agent in the web page.
3. If a step goes wrong, `git checkout -f step-N` loads the tested version of that step.

llama3.2 (3B) handles tools unevenly: it sometimes calls a tool for a question that doesn't need one, writes a tool call as text instead of making it, or invents sources. These failures are worth showing; step 11 compares another model.

## Part 1: Memory

### Step 1: Stateless chat

The model is a function: text in, text out. It remembers nothing.

```text
Replace app.py with a chat page: a title, st.chat_input, and for each message, send ONLY that message to the model and show the question and the answer with st.chat_message. Keep no history.
```

Demo: "My name is Alexis." then "What is my name?". It doesn't know, and the previous exchange disappears from the page: Streamlit reruns the whole file for each message.

### Step 2: Conversation history

In-session memory is the harness resending the whole conversation every turn.

```text
Keep the conversation history in st.session_state.messages: add every user message and model reply, send the full list on each turn, and show the whole conversation on the page. In the sidebar, show how many messages are sent and their approximate size in tokens (total characters divided by 4).
```

Demo: the name question now works. Watch the size grow in the sidebar: that is the context window filling up. Reload the page: everything is gone.

### Step 3: System prompt

The harness decides who the model is before the user says anything.

```text
Read a system prompt from system.md on every run and put it first in the messages list (do not show it in the chat). Show it in the sidebar. Create system.md with: "You are a research assistant. Answer in 3 sentences or fewer. Say when you don't know."
```

Demo: ask a question, then add "Answer only in French." to system.md and send another message: no reload needed.

### Step 4: Persistent memory

Memory across sessions is a file the harness reads and writes.

```text
Add memory that survives page reloads. Add a "Save memory" button in the sidebar: it asks the model to list the lasting facts about the user as bullet points and saves them to memory.md. On every run, read memory.md and add its content to the system prompt. Show memory.md in the sidebar.
```

Demo: "Hi, I'm Alexis, I work in consulting and I prefer short answers.", click Save memory, reload the page, "What do you know about me?". Open memory.md: plain text anyone can read or edit.

## Part 2: Tools

### Step 5: First tool and the agent loop

The model can't act; it can only ask. The harness runs the function and sends back the result. This loop is what makes it an agent.

```text
Add tool calling. Write a Python function get_current_datetime() with the docstring "Get today's date and the current time. Use only when the user asks about the date or time." and pass it to ollama.chat as a tool. Implement the agent loop: if the reply contains tool calls, run each function, append the result as a "tool" message, and call the model again; repeat until the model replies with plain text. If a tool fails, send the error back to the model as text. Store the model's messages with message.model_dump(exclude_none=True). In the chat, show each tool call as a grey [harness] caption and each tool result in an expander. List the tools in the sidebar.
Add to system.md: "You have tools, but most questions do not need them. If no tool clearly matches the question, answer directly from your own knowledge without calling any tool. When a tool returns a result, trust it and use it in your answer."
```

Demo: before this step, ask "What is today's date?" (it guesses or refuses). After, ask again and open the tool result. Then ask "Who wrote Les Misérables?": llama3.2 often calls the date tool anyway.

### Step 6: Local files

Tools give the agent reach; the harness decides how far.

```text
Add three file tools, all restricted to the docs/ folder (refuse any path outside it):
- list_files() lists the files in docs/
- read_file(name) returns a file's text; if the file does not exist, return "No file named ... Files available: ..."
- write_file(name, content) writes a file, but only if an "Allow file writes" toggle in the sidebar is on; otherwise return "The user refused: file writes are switched off."
Show the files in docs/ in the sidebar.
```

`docs/` already holds two sample files that contradict each other.

Demo: "Which files do I have?" first (llama3.2 guesses file names otherwise), then "Do the press release and the interview notes agree on the budget?", then "Save a two-line summary of the contradiction to summary.md" with the toggle off, then on.
Prompt injection: `cp extras/injection.txt docs/minutes.txt`, then "Summarize the file minutes.txt". The file contains a hidden instruction. Results vary with llama3.2: it may repeat the planted claim ("the committee approved the budget") as fact, or try to write a file; with the toggle off, any write is blocked.

### Step 7: Web search

The model's knowledge stops at its training date; search brings in current sources.

```text
Add a web_search(query) tool using the tavily-python library. Read the key from the TAVILY_API_KEY environment variable; if it is missing, return "Web search is unavailable: TAVILY_API_KEY is not set." Return the top 3 results as title, URL and the first 300 characters. Add to system.md: "When you use web search, cite the URLs of your sources."
```

Demo: ask about something from this week. Compare with the step-6 version (`git checkout -f step-6`).

### Step 8: Memory as a tool

Instead of the user clicking "Save memory", the model decides what to remember, and when.

```text
Replace the "Save memory" button with a remember(fact) tool that appends one line to memory.md. Keep loading memory.md on every run. Add to system.md: "When the user shares a lasting fact about themselves (name, job, preferences), call remember."
```

Demo: "Hi, I'm Alexis and I'm vegetarian." and watch the tool call. Reload, then "Suggest a dinner for me tonight." Discuss: what should an agent be allowed to remember, and who checks?

## Part 3: Standard extensions

### Step 9: MCP

Instead of writing each tool, plug in a server that offers ready-made ones over a standard protocol.

```text
Connect the agent to an MCP server with the official mcp Python SDK (version 2 or later: tool schemas are in tool.input_schema). The server is started with `uvx mcp-server-fetch` over stdio. Write one async function that starts the server and either lists its tools or calls one, and run it with asyncio.run. List the MCP tools once (st.cache_resource), convert them to Ollama tool definitions, and add them to the tools sent to the model. When the model calls an MCP tool, drop arguments whose value is None, then call it on the server. Show the MCP tools in the sidebar.
```

Demo: "Fetch https://en.wikipedia.org/wiki/Large_language_model and summarize it in two sentences." No fetch code was written in app.py: the same server works in Claude, OpenCode or Cursor.

### Step 10: Skills

A skill is a written procedure the agent loads only when it needs it. The system prompt holds just the index.

```text
Add skills. Each skill is a folder in skills/ containing a SKILL.md that starts with a header between --- lines, giving a name and a one-line description. Add only the names and descriptions to the system prompt, and show them in the sidebar. Add a load_skill(name) tool that returns the full SKILL.md. Create skills/fact-check/SKILL.md: restate the claim, find two independent sources with web_search, give one line per source with its URL, then a verdict (TRUE, FALSE or UNVERIFIED). Never invent sources.
```

Demo: "Fact-check this claim: France is the most visited country in the world." Watch load_skill. In tests, llama3.2 loaded the skill but then skipped web_search and cited sources from memory: compare the URLs with the tool results. Then write a second skill live, in plain English, with no code.

### Step 11: Same harness, different model

The harness stays; the model is a swappable part.

```text
Replace the fixed MODEL with a selectbox in the sidebar listing the models downloaded in Ollama (ollama.list()), with llama3.2 selected by default.
```

Demo: `ollama pull qwen2.5:3b` in a terminal, reload the page, pick it, and repeat the fact-check. In tests, qwen2.5:3b called web_search every time but skipped the skill. Close by noting that OpenCode, which wrote all of this, is the same kind of harness around a much larger model.
