# Context is All You Need: Agentic CLI Setup

> **Supercharge your programming workflow with AI agents that actually understand your project**

This repository implements the structured context framework described in the article ["Context is All You Need: How to Supercharge Your Programming Workflow using Agentic CLI Tools"](./article.md). It addresses the critical "learning gap" that causes 95% of AI projects to fail by providing LLMs with comprehensive project context through a "briefing packet" approach.

DISCLAIMER: Everything in this repo should be taken as an example. I don't guarantee/ claim that the code provided in the read me or anywhere works fully. This repo is only for illustration purposes.

## 🎯 The Problem & Solution

**The Problem**: Generic LLMs fail in production because they lack project-specific context. They don't understand your architectural decisions, business requirements, or codebase patterns.

**The Solution**: Treat your AI as a brilliant new team member who needs onboarding. Provide structured context through:
- **Architectural Decision Records (ADRs)** - The "why" behind technical choices
- **User Stories** - The "who" and "what" of features  
- **OpenAPI Specifications** - The "how" of API interactions
- **Data Schemas** - The "language" of your data

This enables the **"Plan, Propose, Proceed"** pattern for safe, effective agentic workflows.

## 🚀 Quick Start

1. **Choose your AI CLI tool** (see installation options below)
2. **Set up MCP servers** for enhanced capabilities
3. **Organize your documentation** using the provided templates
4. **Brief your AI agent** and start building better software faster

## 🛠️ LLM CLI Tools Installation

### Claude Code (Recommended)

Anthropic's official CLI with advanced MCP support, hooks, and subagents.

**Installation:**
```bash
# Install Claude Code CLI
npm install -g @anthropic-ai/claude-cli

# Authenticate
claude auth login

# Verify installation
claude --version
```

**Quick MCP Setup:**
```bash
# Add Context7 for up-to-date docs
claude mcp add context7 -- npx -y @upstash/context7-mcp

# Add GitHub integration
claude mcp add github --transport http https://api.githubcopilot.com/mcp \
  -H "Authorization: Bearer YOUR_GITHUB_TOKEN"

# Verify setup
claude mcp list
```

**Features**: Hooks, Subagents, Deep workflow automation, MCP protocol support

📖 **Detailed Setup**: [Claude Code Setup Guide](./docs/mcp-installation/claude-code-setup.md)

---

### Gemini CLI

Google's open-source CLI with 1M context window and ReAct loops.

**System Requirements:**
- Node.js version 20 or higher
- macOS, Linux, or Windows

**Quick Install (No Installation Required):**
```bash
# Run instantly with npx
npx https://github.com/google-gemini/gemini-cli
```

**Install Globally:**
```bash
# Option 1: npm
npm install -g @google/gemini-cli

# Option 2: Homebrew (macOS/Linux)
brew install gemini-cli

# Verify installation
gemini --version
```

**Quick MCP Configuration:**
```bash
# Edit ~/.gemini/settings.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token"
      }
    }
  }
}

# Test setup
gemini
/mcp  # List configured servers
```

**Features**: 1M token context, Google Cloud integration, Native search, ReAct reasoning

📖 **Detailed Setup**: [Gemini CLI Setup Guide](./docs/mcp-installation/gemini-cli-setup.md)

---

### OpenAI Codex CLI

For rapid prototyping and direct OpenAI model access.

**Installation:**
```bash
# Install via pip
pip install openai-codex-cli

# Authenticate
export OPENAI_API_KEY="your-api-key"
codex auth

# Verify installation
codex --version
```

**Quick Setup:**
```bash
# Basic configuration
codex config set model gpt-5
codex config set max_tokens 2000

# Test
codex "Hello, world in Python"
```

**Features**: Direct OpenAI access, Approval modes, Rapid prototyping

📖 **Documentation**: [OpenAI CLI Documentation](https://github.com/openai/openai-cli)

## 📁 Documentation Structure

This repository provides a complete context framework organized as follows:

### 🏗️ **Architecture & Decisions**
```
docs/adr/
├── adr-001-llm-context-architecture.md    # Why structured context matters
└── adr-002-mcp-server-selection.md        # MCP server strategy & security
```
*Documents the "why" behind technical decisions to prevent AI from suggesting rejected solutions.*

### 📋 **Requirements & User Stories**
```
docs/user-stories/
├── user-story-template.md                 # Standard template
└── user-story-001-ai-agent-context.md     # Example implementation
```
*Defines business objectives so AI generates functionally relevant code.*

### 🔧 **Technical Specifications**
```
docs/openapi-specs/
└── mcp-server-api.yaml                    # MCP server API definition

docs/pydantic/
└── context-models.py                      # Type-safe data models

docs/database-schema/
└── agent-context-schema.sql              # Database structure
```
*Provides precise technical contracts for accurate AI-generated code.*

### ⚙️ **Installation & Setup**
```
docs/mcp-installation/
├── claude-code-setup.md                   # Complete Claude Code + MCP guide
└── gemini-cli-setup.md                    # Complete Gemini CLI + MCP guide
```
*Step-by-step setup instructions with security best practices.*

## 🎯 Getting Started Workflow

### 1. Install Your Preferred CLI Tool
Choose from Claude Code, Gemini CLI, or OpenAI Codex CLI based on your needs.

### 2. Set Up Core MCP Servers
Start with these essential servers:
- **Context7**: Up-to-date library documentation
- **GitHub**: Repository operations and issue management
- **Filesystem**: Local file operations with security
- **Sequential Thinking**: Complex problem breakdown

### 3. Create Your Context Documents
Using the provided templates:
```bash
# Copy templates to your project
cp docs/adr/adr-xxx-title-template.md your-project/docs/adr/
cp docs/user-stories/user-story-template.md your-project/docs/user-stories/
```

### 4. Brief Your AI Agent
Point your AI to the context documents:
```
"Load the project context from ./docs and help me implement user authentication 
following the patterns documented in our ADRs."
```

## ✨ Key Features & Benefits

### 🧠 **Context-Driven Development**
- Eliminates the 95% failure rate of generic AI approaches
- Provides project-specific, accurate suggestions
- Maintains architectural consistency

### 🔌 **MCP Server Integration**
- **Context7**: Real-time library documentation
- **GitHub**: Direct repository integration
- **Filesystem**: Secure local file access
- **Custom servers**: Extensible for your specific needs

### 📖 **Structured Documentation**
- ADRs capture the "why" behind decisions
- User stories define clear business objectives
- Schemas ensure data consistency
- APIs provide precise contracts

### 🛡️ **Plan, Propose, Proceed Pattern**
- **Plan**: AI generates detailed execution plan
- **Propose**: Shows changes before execution  
- **Proceed**: Executes only with explicit approval

### 👥 **Team Collaboration**
- Reusable context across team members
- Consistent AI behavior for everyone
- Knowledge preservation and onboarding

## 🏃‍♂️ Quick Examples

### Document an Architectural Decision
```bash
# Use the ADR template
cp docs/adr/adr-xxx-title-template.md docs/adr/adr-004-database-choice.md
# Fill in your decision rationale
```

### Create a User Story
```bash
# Use the user story template
cp docs/user-stories/user-story-template.md docs/user-stories/us-002-oauth-integration.md
# Define your feature requirements
```

### Set Up Context-Aware AI Session
```bash
# With Claude Code
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem ./docs
# Now ask: "Review our architectural decisions and suggest an implementation approach"

# With Gemini CLI
# Configure filesystem access in ~/.gemini/settings.json
# Then: "Read our project documentation and help implement the next feature"
```

## 🔧 Advanced Configuration

### Multiple MCP Servers
Configure various servers for different capabilities:
- **Database access**: PostgreSQL, MySQL, SQLite servers
- **Cloud services**: AWS, GCP, Azure integrations
- **Development tools**: Docker, Kubernetes, CI/CD
- **Communication**: Slack, Discord, email notifications

### Custom Context Types
Extend beyond the basic templates:
- **API Documentation**: Swagger/OpenAPI specs
- **Database Schemas**: Entity relationships and constraints
- **Coding Standards**: Style guides and conventions
- **Deployment Configs**: Infrastructure as code

### Security Best Practices
- Use environment variables for API keys
- Implement least-privilege access for MCP servers
- Regular security audits of installed servers
- Container isolation for untrusted servers

## 📚 Additional Resources

- **Original Article**: [article.md](./article.md) - The complete philosophy and methodology
- **MCP Documentation**: [Model Context Protocol](https://modelcontextprotocol.io/)
- **Claude Code Docs**: [Anthropic Documentation](https://docs.anthropic.com/en/docs/claude-code)
- **Gemini CLI**: [Google's Repository](https://github.com/google-gemini/gemini-cli)

---

## 💡 Remember: You're Still the Pilot

These tools don't replace developers—they **empower** them. By offloading repetitive tasks and providing rich context, they free you to focus on **architecture, creativity, and problem-solving**. 

The AI generates the code, but *you* provide the vision and goals. **Context is all you need** to transform from struggling with generic AI suggestions to having a powerful, project-aware coding partner.

**Start small**: One project, one context document, one CLI tool. You might be surprised how much faster you can fly. ✈️
