# Claude Code Agents Collection

> **Specialized AI agents aligned with the structured context framework**

This collection provides production-ready Claude Code agents that implement the "Context is All You Need" philosophy. Each agent is designed to work seamlessly with our structured documentation framework and MCP server integrations.

## 🎯 Agent Philosophy

These agents embody the principles from our [context architecture ADR](../adr/adr-001-llm-context-architecture.md):

- **Context-Aware**: Understand and leverage your project's ADRs, user stories, and schemas
- **MCP-Integrated**: Work with Context7, GitHub, filesystem, and other MCP servers
- **Security-First**: Follow the "Plan, Propose, Proceed" pattern for safe operations
- **Framework-Aligned**: Consistent with your structured documentation approach

## 📁 Agent Categories

### 🏗️ **Development Architecture** (`development/`)
- **context-architect.md** - Implements structured context framework
- **code-reviewer.md** - Security-focused code review with ADR awareness
- **api-designer.md** - OpenAPI-first API design following user stories

### ⚙️ **Infrastructure Operations** (`infrastructure/`)
- **mcp-configurator.md** - MCP server setup and management
- **docker-specialist.md** - Container and deployment expert

### 🔍 **Quality & Security** (`quality/`)
- **test-engineer.md** - Testing strategy aligned with acceptance criteria
- **documentation-writer.md** - ADR, user story, and technical doc creation

### 🎯 **Specialized Domains** (`specialized/`)
- **pydantic-modeler.md** - Data model and schema expert
- **database-architect.md** - Database design with Pydantic integration

## 🚀 Quick Installation

### Install All Agents (User-wide)
```bash
# From this repository root
find docs/agents -name "*.md" -not -name "README.md" -not -name "*template*" \
  -exec cp {} ~/.claude/agents/ \;

# Restart Claude Code
```

### Install Specific Agents
```bash
# Install just the context architect
cp docs/agents/development/context-architect.md ~/.claude/agents/

# Install MCP configurator
cp docs/agents/infrastructure/mcp-configurator.md ~/.claude/agents/

# Restart Claude Code
```

### Project-Specific Installation
```bash
# Create project agents folder
mkdir -p .claude/agents

# Copy specific agents for this project
cp docs/agents/development/context-architect.md .claude/agents/
cp docs/agents/quality/code-reviewer.md .claude/agents/

# Restart Claude Code
```

## 🎪 Agent Usage Examples

### Context Architect Agent
```
"Use the context architect to set up structured documentation for this new microservice project following our ADR framework."
```

### MCP Configurator Agent  
```
"Configure Context7 and GitHub MCP servers for this repository using our security guidelines."
```

### Code Reviewer Agent
```
"Review this authentication implementation against our documented security ADRs and user story requirements."
```

### API Designer Agent
```
"Design a RESTful API for user management following the OpenAPI spec template and US-001 requirements."
```

## 🔧 Configuration & Customization

### Tool Restrictions
Many agents have restricted tool access for security and performance:

```yaml
# Example from code-reviewer.md
---
name: code-reviewer
tools: Read, Grep, Git
---
```

### Project Integration
Agents automatically reference:
- **ADRs** (`docs/adr/`) - Architectural decisions and rationale
- **User Stories** (`docs/user-stories/`) - Business requirements
- **OpenAPI Specs** (`docs/openapi-specs/`) - API contracts
- **Schemas** (`docs/database-schema/`, `docs/pydantic/`) - Data models

### MCP Server Integration
Agents leverage configured MCP servers:
- **Context7** - Up-to-date library documentation
- **GitHub** - Repository operations and history
- **Filesystem** - Local file access with security
- **Sequential Thinking** - Complex problem breakdown

## 📋 Creating Custom Agents

### 1. Use the Template
```bash
cp docs/agents/agent-template.md docs/agents/specialized/my-agent.md
```

### 2. Follow the Structure
```yaml
---
name: my-agent
description: Clear description of when to invoke this agent
category: specialized-domains
tools: Read, Write, Edit  # Optional - restrict tools if needed
---

You are a [role description].

When invoked:
1. [First action - analyze requirements]
2. [Second action - review context]
3. [Third action - plan approach]
4. [Fourth action - implement solution]

Process:
- [Key methodology or principle]
- [Best practice to follow]
- [Important consideration]

Provide:
- [Specific deliverable with format]
- [Testing or validation approach]
- [Documentation or examples]

Always reference relevant ADRs and user stories when making decisions.
```

### 3. Test and Validate
```bash
# Install your agent
cp docs/agents/specialized/my-agent.md ~/.claude/agents/

# Test with Claude Code
# "Use my-agent to help with..."
```

## 🛡️ Security & Best Practices

### Agent Security
- **Tool Restrictions**: Most agents have limited tool access
- **Read-Only First**: Agents analyze before proposing changes
- **ADR Compliance**: All suggestions align with documented decisions
- **Approval Required**: Complex operations follow "Plan, Propose, Proceed"

### Safe Usage Patterns
```bash
# Good: Specific, context-aware requests
"Use the code reviewer to analyze this JWT implementation against ADR-003"

# Good: Clear scope and constraints  
"Use the API designer to create endpoints for user stories US-001 through US-003"

# Avoid: Vague requests without context
"Make this code better"
```

## 🔄 Agent Updates & Maintenance

### Keeping Agents Current
```bash
# Update from repository
git pull origin main
find docs/agents -name "*.md" -not -name "README.md" -not -name "*template*" \
  -exec cp {} ~/.claude/agents/ \;
```

### Version Compatibility
- Agents are tested with Claude Code's latest stable version
- MCP server integrations follow current protocol specifications
- Regular updates ensure compatibility with framework changes

## 🐛 Troubleshooting

### Agent Not Available
```bash
# Check installation
ls ~/.claude/agents/          # User agents
ls .claude/agents/            # Project agents

# Verify agent format
head -20 ~/.claude/agents/context-architect.md
```

### Tool Access Issues
```bash
# Check MCP server status in Claude Code
/mcp

# List available tools
/tools
```

### Performance Issues
- **Tool Limitations**: Agents with restricted tools perform better
- **Context Size**: Large projects may hit token limits
- **MCP Latency**: Remote MCP servers may have network delays

## 📚 Integration Examples

### With Existing Workflow
```bash
# 1. Set up project context
"Use context-architect to create ADR structure for this new service"

# 2. Configure tooling
"Use mcp-configurator to set up GitHub and Context7 integration"

# 3. Implement features
"Use api-designer to create user authentication endpoints per US-001"

# 4. Review and test
"Use code-reviewer to validate implementation against security ADRs"
```

### Team Collaboration
```bash
# Share project-specific agents
git add .claude/agents/
git commit -m "Add project-specific Claude Code agents"

# Document agent usage in project README
echo "## AI Agent Usage" >> README.md
echo "See docs/agents/ for available Claude Code agents" >> README.md
```

## 📖 Additional Resources

- **Claude Code Documentation**: [Anthropic's Official Docs](https://docs.anthropic.com/en/docs/claude-code)
- **MCP Setup Guides**: [Claude Code Setup](../mcp-installation/claude-code-setup.md) | [Gemini CLI Setup](../mcp-installation/gemini-cli-setup.md)
- **Context Framework**: [ADR-001](../adr/adr-001-llm-context-architecture.md) | [User Story Template](../user-stories/user-story-template.md)
- **Original Article**: [Context is All You Need](../../article.md)

## 🤝 Contributing

1. **Follow the Template**: Use `agent-template.md` as the base
2. **Test Thoroughly**: Validate agent behavior with real scenarios
3. **Document Integration**: Show how the agent works with our framework
4. **Submit PR**: Include usage examples and testing results

---

**Remember**: These agents are designed to work with *your* structured context. They understand your ADRs, user stories, and technical specifications, making them powerful partners in your development workflow. 🚀