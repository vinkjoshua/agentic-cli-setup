# Claude Code MCP Server Setup Guide

## Overview

This guide walks you through installing and configuring Model Context Protocol (MCP) servers with Claude Code, specifically focusing on Context7 and GitHub integrations that align with our structured context framework described in [ADR-002: MCP Server Selection](../adr/adr-002-mcp-server-selection.md).

## Prerequisites

- Claude Code CLI installed and authenticated
- Node.js and npm (for NPX-based servers)
- Docker (for containerized servers)
- Git (for repository operations)

## Basic MCP Commands

Claude Code provides a simple CLI interface for managing MCP servers:

```bash
# Add a server
claude mcp add <name> <command> [args...]

# List installed servers
claude mcp list

# Remove a server
claude mcp remove <name>

# Test a server connection
claude mcp get <name>

# Update server configuration
claude mcp update <name> [options]
```

## Core MCP Server Installation

### 1. Context7 Server (Up-to-date Documentation)

Context7 provides real-time, version-specific documentation and code examples directly from source repositories.

#### Installation Options

**Option A: Remote Server (Recommended)**
```bash
claude mcp add --transport http context7 https://mcp.context7.com/mcp \
  --header "CONTEXT7_API_KEY: YOUR_API_KEY"
```

**Option B: NPX Local Installation**
```bash
claude mcp add context7 --env CONTEXT7_API_KEY=YOUR_API_KEY \
  -- npx -y @upstash/context7-mcp
```

**Option C: SSE Transport**
```bash
claude mcp add --transport sse context7 https://mcp.context7.com/sse \
  --header "CONTEXT7_API_KEY: YOUR_API_KEY"
```

#### Getting API Key (Optional)

While Context7 works without an API key, having one provides higher rate limits:

1. Visit [context7.com/dashboard](https://context7.com/dashboard)
2. Create an account
3. Generate an API key
4. Use it in your configuration

#### Usage

After installation, append `use context7` to any prompt to fetch up-to-date documentation:

```
How do I implement JWT authentication? use context7
```

### 2. GitHub MCP Server (Repository Operations)

⚠️ **Important**: As of April 2025, the npm package `@modelcontextprotocol/server-github` is deprecated. Use the official GitHub MCP server instead.

#### Prerequisites

1. **Create GitHub Personal Access Token (PAT)**:
   - Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
   - Generate new token with `repo` scope
   - Copy the token securely

2. **Secure Token Storage** (Recommended):
   ```bash
   # Create .env file in your project root
   echo "GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token_here" >> .env
   echo ".env" >> .gitignore
   ```

#### Installation Options

**Option A: Remote Server (Recommended for 2025)**
```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp \
  -H "Authorization: Bearer YOUR_GITHUB_PAT"
```

**Option B: Local Docker Setup**
```bash
claude mcp add github \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=YOUR_GITHUB_PAT \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN \
  ghcr.io/github/github-mcp-server
```

**Option C: Legacy NPX (Not recommended after April 2025)**
```bash
# This method is deprecated but may still work
claude mcp add github \
  -e GITHUB_PERSONAL_ACCESS_TOKEN=YOUR_GITHUB_PAT \
  -- npx -y @modelcontextprotocol/server-github
```

### 3. Filesystem Server (Local File Operations)

For secure local file operations with configurable permissions.

```bash
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem \
  /path/to/allowed/dir1 /path/to/allowed/dir2
```

**Docker Alternative:**
```bash
claude mcp add filesystem -- docker run -i --rm \
  --mount type=bind,src=/Users/username/projects,dst=/projects \
  mcp/filesystem /projects
```

### 4. Sequential Thinking Server (Complex Reasoning)

For breaking down complex problems into manageable steps.

```bash
claude mcp add sequential-thinking \
  -- npx -y @modelcontextprotocol/server-sequential-thinking
```

## Configuration Scopes

Claude Code supports three configuration scopes:

### Local Scope
Private to the current project directory:
```bash
claude mcp add --scope local myserver -- command args
```

### Project Scope
Shared via `.mcp.json` file in project root:
```bash
claude mcp add --scope project myserver -- command args
```

### User Scope (Default)
Available across all projects:
```bash
claude mcp add --scope user myserver -- command args
```

## Advanced Configuration

### Environment Variables

Securely pass environment variables to MCP servers:

```bash
claude mcp add github \
  --env GITHUB_PERSONAL_ACCESS_TOKEN=ghp_token \
  --env GITHUB_ORG=my-organization \
  -- docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN -e GITHUB_ORG \
  ghcr.io/github/github-mcp-server
```

### Authentication with OAuth 2.0

For servers that support OAuth 2.0:

```bash
/mcp
# Follow the authentication flow in Claude Code
```

### Custom Headers

Add custom headers for API authentication:

```bash
claude mcp add api-server --transport http \
  --header "X-API-Key: your-api-key" \
  --header "User-Agent: MyApp/1.0" \
  https://api.example.com/mcp
```

## Verification and Testing

After installing MCP servers, verify they're working correctly:

```bash
# List all servers and their status
claude mcp list

# Test a specific server
claude mcp get context7

# Check server tools (within Claude Code session)
/tools

# Check MCP server status
/mcp
```

## Troubleshooting

### Debug Mode

Launch Claude Code with debug mode for detailed MCP logs:

```bash
claude --mcp-debug
```

### Common Issues

1. **Authentication Failures**
   - Verify API keys and tokens
   - Check token expiration dates
   - Ensure proper scopes for GitHub PAT

2. **Connection Issues**
   - Check network connectivity
   - Verify server URLs
   - Test with `curl` for HTTP servers

3. **Docker Issues**
   - Ensure Docker is running
   - Check image availability
   - Verify mount paths for filesystem access

4. **NPX Issues**
   - Update Node.js and npm
   - Clear npm cache: `npm cache clean --force`
   - Try global installation: `npm install -g package-name`

### Configuration File Location

If you need to manually edit configurations:

**macOS/Linux:**
```
~/.config/claude/claude_config.json
```

**Windows:**
```
%APPDATA%\claude\claude_config.json
```

## Security Best Practices

1. **Trust Levels**: Only install MCP servers from trusted sources
2. **Permissions**: Use Docker containers to limit filesystem access
3. **Tokens**: Store sensitive tokens in environment variables or `.env` files
4. **Network**: Use HTTPS for remote servers when possible
5. **Auditing**: Monitor MCP server usage and logs regularly

## Example Project Setup

Here's a complete setup for a typical development project:

```bash
# Navigate to your project
cd /path/to/your/project

# Set up environment
echo "GITHUB_PERSONAL_ACCESS_TOKEN=ghp_your_token" > .env
echo "CONTEXT7_API_KEY=your_context7_key" >> .env
echo ".env" >> .gitignore

# Install core MCP servers
claude mcp add --scope project context7 \
  --env CONTEXT7_API_KEY=YOUR_CONTEXT7_KEY \
  -- npx -y @upstash/context7-mcp

claude mcp add --scope project github \
  --transport http https://api.githubcopilot.com/mcp \
  -H "Authorization: Bearer YOUR_GITHUB_PAT"

claude mcp add --scope project filesystem \
  -- npx -y @modelcontextprotocol/server-filesystem $(pwd)

# Verify setup
claude mcp list
```

## Integration with Context Framework

Once MCP servers are installed, they integrate seamlessly with your structured context framework:

1. **Context7** automatically fetches relevant documentation when you reference libraries
2. **GitHub MCP** allows Claude to read your ADRs, user stories, and other documentation
3. **Filesystem MCP** enables direct access to your project's context documents

This creates a powerful environment where Claude has access to:
- Your project's architectural decisions (via filesystem/GitHub)
- Up-to-date library documentation (via Context7)
- Repository history and issues (via GitHub)
- Local development files (via filesystem)

## Next Steps

After setting up these MCP servers:

1. Create a `CLAUDE.md` file in your project root with context instructions
2. Organize your documentation following the structure in [ADR-001](../adr/adr-001-llm-context-architecture.md)
3. Test the integration by asking Claude to analyze your project structure
4. Gradually add more specialized MCP servers as needed

For Gemini CLI setup, see the [Gemini CLI Configuration Guide](./gemini-cli-setup.md).