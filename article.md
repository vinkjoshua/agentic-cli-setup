# Context is All You Need: How to Supercharge Your Programming Workflow using Agentic CLI Tools

As an AI/ML consultant, I'd say I’m quite good at creating logic for complex problems, but I sometimes struggle with finding the correct code to accompany that logic. Don't get me wrong, I love creating software and building great statistical or ML models, especially if it means I can bring smiles to stakeholders' faces. But I hate finding the correct syntax or the right arguments in a function that holds a bazillion parameters. I see coding more as a means to an end.

In the last few years, you've probably seen headlines about LLMs reaching star-status programming levels and Google's models achieving gold-level mathematics. But when you try to implement code yourself, it often feels like you're talking to a stubborn teenager. It gets things wrong, or doesn't fully grasp what you mean, which leads to a frustrating experience for everyone involved. So how can the big AI providers be showing off state-of-the-art models that are breaking all barriers known to man, while your personal experience feels more like a novice programmer who tries to teach you the most complex of tools?

Well, it's all because you're not providing sufficient context. In this article, I want to go over how to improve your day-to-day programming workflow by introducing you to AI agents that use your Command Line Interface (CLI) to help you develop production-ready code, while also keeping your sanity in check, all the while providing the LLM the context that it needs.

---

## The Great AI Disappointment (And How to Fix It)

You're not alone in feeling this disconnect. A recent MIT study, *"The GenAI Divide: State of AI in Business 2025,"* sent shockwaves through the tech world by reporting that a staggering 95% of generative AI business projects are failing to deliver meaningful results. This is despite more than $44 billion being invested in AI startups and enterprise tools in just the first half of 2025. The report suggests that most projects collapse under the weight of unrealistic expectations, poor integration, and a lack of specialized adaptation.  

Now, before we all pack it in and go back to manually searching Stack Overflow, it's worth noting that this headline-grabbing statistic has its critics. Paul Roetzer of the Marketing AI Institute, for one, argues that the study's methodology is flawed. He points out that "success" was very narrowly defined as achieving a measurable ROI within just six months of a pilot, which ignores a ton of other critical business impacts like efficiency gains, cost reductions, or simply making developers' lives easier. The study's finding of "zero return" was also based on a small sample of just 52 interviews.  

So, what's the real story? The truth, as always, is somewhere in the middle. Whether the failure rate is 95% or 50%, the study points to a universal pain point that every developer has felt: the **"learning gap".** Generic, off-the-shelf AI models fail because they don't actually know what you're talking about. They lack *context.*

This isn't a sign that AI is overhyped, but rather that we're moving out of the initial hype cycle and into a more mature, pragmatic phase. The bottleneck for developer productivity is no longer the speed at which we can type code; it's the speed and quality at which we can communicate our goals, constraints, and architectural decisions to an AI partner. The developer's role is evolving from a pure coder into an "AI collaborator" or "system briefer." Your most valuable skill is no longer just writing code, but effectively explaining the *why* and the *how* behind it.

---

## Context is King: Briefing Your New AI Colleague

The most common way developers interact with LLMs—pasting a snippet of code into a web-based chat window and asking for a change—is fundamentally flawed for any non-trivial software project. This approach treats context as ephemeral. The knowledge you provide is lost the moment the session ends, it isn't reusable by your teammates, and most critically, it lacks the "why" behind the code.

To truly elevate an LLM's performance, you need to treat it not as an all-knowing oracle, but as a brilliant new colleague who just joined your team. They're incredibly fast and know every programming language under the sun, but they have zero knowledge of your project's history, goals, or quirks. You need to onboard them. This means creating a "briefing packet" of durable, structured, and rationale-driven context.

This philosophy aligns with the Context-Driven School of software development, which holds a simple but powerful principle: *"There are good practices in context, but there are no best practices."* The right way to build software depends entirely on the specific project, team, and goals. Your job is to provide that context to your AI teammate. Here’s what should be in your briefing packet:  

### Architectural Decision Records (ADRs)
When starting a project, you need a plan. If you don't have one, why in the hell have you started coding?! An architecture diagram is your map, but ADRs are your travel log. They are short text documents that capture the "why" behind important architectural decisions. Why did we choose PostgreSQL over MongoDB? Why are we using a microservices architecture instead of a monolith?

Providing these to an LLM is crucial. It prevents the agent from wasting time suggesting solutions that your team has already considered and rejected for good reasons. It gives the AI a history lesson, allowing it to make suggestions that are consistent with your project's established principles.  

👉 [Basics of Architecture Decision Records (ADR)](https://medium.com/@nolomokgosi/basics-of-architecture-decision-records-adr-e09e00c636c6)

### User Stories (The "Who" and "What")
Well-defined user stories, typically following the format *"As a [user role], I want to [action], so that [goal or benefit],"* provide the LLM with the business objective for a given task. This crucial piece of context prevents the agent from generating code that is technically correct but functionally useless. Including clear acceptance criteria is vital for defining what "done" means for a task, giving the LLM a concrete target for its implementation.

### OpenAPI Specs (The "How" of APIs)
For any project that exposes or consumes APIs, an OpenAPI specification serves as a machine-readable contract. Providing this specification to an LLM allows it to understand endpoints, request and response formats, data types, and authentication methods without guesswork. This enables the agent to generate accurate client code, create correct API calls, or even use the API as a tool.

### Data(base) Schemas (The "Language" of Data)
The database schema defines the vocabulary of an application's data. Supplying the schema to an LLM, especially when enriched with descriptive comments and clear, self-explanatory naming conventions, is essential for tasks like text-to-SQL generation.  

Furthermore, I recommend using **Pydantic models** for any other data contracts needed within your application. This also provides better context for the LLM.

---

## From Assistant to Agent: Putting Your Context to Work

Okay, so you've built your kingdom of context. You have a folder full of beautiful Markdown files, schemas, and specs. Now what? Now, we graduate from using a simple AI assistant to deploying an **AI agent**.

What's the difference? Think of it like this: asking an assistant is like telling a junior dev, *"Hey, can you fix the typo on line 42 of auth.js?"* Asking an agent is like handing them a bug ticket that says *"Users can't log in"* and telling them to figure it out.

An **agentic workflow** is an AI-driven process where an autonomous agent makes decisions, plans a course of action, and uses tools to accomplish a complex goal with minimal human intervention.  

---

### A Safe Agentic Flow: The "Plan, Propose, Proceed" Pattern

Now, I know what you're thinking. *"Let an AI run wild in my codebase? No, thank you!"* And you're right to be cautious. My personal rule is to never let an LLM go completely unsupervised. I prefer a guided, step-by-step approach that keeps me in the driver's seat. Others have coined it the **"Plan, Propose, Proceed" pattern.**

1. **Plan:** You give the agent a task. It generates a step-by-step plan based on your context.
2. **Propose:** The agent presents the plan for your approval before making changes.
3. **Proceed:** Only after approval does the agent execute, edit files, and run tests.

This workflow gives you the power of an autonomous agent without sacrificing control.  

---

## Level Up with Claude Code: Your AI's New Superpowers

To really unlock these agentic workflows, you need a tool that's built for it. While there are several great options, my personal favorite is **Anthropic's Claude Code**.

### MCP Servers: Giving Your Agent Arms and Legs
MCP (Model Context Protocol) lets Claude Code connect to external tools. Think of MCP servers as plugins that give your agent the ability to interact with the world beyond your terminal.  

Examples:
- **GitHub MCP:** Read issues, analyze pull requests, check commits.
- **Context7 MCP:** Stay up-to-date with library docs.

### Subagents: Assembling Your A-Team of Specialists
Claude Code allows you to create **subagents**—specialized AI personalities for specific jobs.  

Examples:
- **CodeReviewer-Agent** (security review).
- **TestWriter-Agent** (unit test generation).

### Hooks: Automating the Annoying Stuff
Hooks are scripts that run automatically at key lifecycle points.  

Examples:
- Auto-format code on edit.
- Auto-commit on task completion.
- Send notifications after long tasks.

---

## Choosing Your Weapon: A Quick Guide to LLM CLIs

Here’s a quick comparison of the top options:

| Feature       | Claude Code | Gemini CLI | OpenAI Codex CLI |
|---------------|-------------|------------|------------------|
| **Key Strength** | Deep workflow automation | Google Cloud integration | Rapid prototyping |
| **Unique Features** | Hooks, Subagents, MCP | Native Google Search, GitHub Actions | Approval modes, direct OpenAI access |
| **Cost Model** | Subscription / Pay-as-you-go | GCP/Gemini quotas | Usage-based / ChatGPT plans |
| **Best For...** | Complex workflows | GCP teams | Quick experiments |
| **Docs** | [Claude Docs](https://docs.anthropic.com/en/docs/claude-code/overview) | [Gemini CLI Docs](https://gemini-cli.xyz/docs) | GitHub |

Pro tip: create a `.md` file in your project root (e.g., `claude.md`, `gemini.md`) with context and coding standards for your AI agent.

---

## Final Thoughts: You're Still the Pilot

Ultimately, these tools are not about replacing developers—they're about **empowerment**. By offloading repetitive tasks, they free us to focus on what matters: **architecture, creativity, and problem-solving.**

Remember that 95% failure statistic? The solution isn't to give AI more control. It's to **give it better context.** The AI can generate the code, but *you* provide the vision and goals. You are still the pilot, but now with a powerful co-pilot.

So go ahead—power up your workflow. Start small: one project, one context doc, one CLI tool. You might be surprised how much faster you can fly.
