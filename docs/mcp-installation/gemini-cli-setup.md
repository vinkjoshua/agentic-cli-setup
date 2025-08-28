# Gemini CLI MCP Server Configuration Guide

## Overview

This guide covers setting up Model Context Protocol (MCP) servers with Google's Gemini CLI, an open-source AI agent that brings Gemini's power directly into your terminal. The Gemini CLI uses a ReAct (Reason and Act) loop with built-in tools and MCP servers to complete complex tasks following our "Plan, Propose, Proceed" pattern.

## What is Gemini CLI?

The Gemini CLI is an open-source AI agent featuring:
- Gemini 2.5 Pro with 1M token context window
- Built-in tools (Google Search, file operations, shell commands, web fetching)
- Extensible MCP (Model Context Protocol) support
- Integration with VS Code via Gemini Code Assist

## Prerequisites

- Node.js version 20 or higher
- macOS, Linux, or Windows
- Google Cloud account with Gemini API access (for advanced features)
- Docker (optional, for containerized MCP servers)
- Git and GitHub account (for repository operations)

## Installation

### Quick Install (No Installation Required)
```bash
# Run instantly with npx
npx https://github.com/google-gemini/gemini-cli
```

### Install Globally
```bash
# Option 1: npm
npm install -g @google/gemini-cli

# Option 2: Homebrew (macOS/Linux)
brew install gemini-cli

# Verify installation
gemini --version
```

### Cloud Shell
Gemini CLI is available without additional setup in Google Cloud Shell.

## MCP Server Configuration

### Configuration File Location

MCP servers are configured in your Gemini settings JSON file:

```
~/.gemini/settings.json
```

### Basic Configuration Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "command-to-run",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

## Core MCP Server Setup

### 1. GitHub MCP Server

The most commonly used MCP server for repository operations.

#### Prerequisites
1. **Create GitHub Personal Access Token**:
   - Go to GitHub Settings > Developer settings > Personal access tokens
   - Generate new token with `repo` scope
   - Copy the token securely

#### Configuration

Add to `~/.gemini/settings.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

#### Alternative: Local Server Installation

```json
{
  "mcpServers": {
    "github": {
      "command": "/path/to/github-mcp-server/cmd/github-mcp-server/github-mcp-server",
      "args": ["stdio"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token_here"
      }
    }
  }
}
```

### 2. Filesystem MCP Server

For local file operations with secure access controls.

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/directory"]
    }
  }
}
```

### 3. Database MCP Servers

#### PostgreSQL/MySQL
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres", "postgresql://user:password@localhost/dbname"]
    }
  }
}
```

### 4. Cloud Services

#### Cloudflare MCP (Remote)
```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "npx",
      "args": ["-y", "cloudflare-mcp-server"],
      "env": {
        "CLOUDFLARE_API_TOKEN": "your_cf_token"
      }
    }
  }
}
```

## Advanced Configuration Examples

### Multiple MCP Servers

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_token_here"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/username/projects"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://user:pass@localhost/db"
      }
    },
    "web-search": {
      "command": "npx",
      "args": ["-y", "web-search-mcp-server"],
      "env": {
        "SEARCH_API_KEY": "your_search_api_key"
      }
    }
  }
}
```

### Docker-based MCP Servers

```json
{
  "mcpServers": {
    "github-docker": {
      "command": "docker",
      "args": [
        "run", "--rm", "-i",
        "--mount", "type=bind,src=/Users/username,dst=/Users/username",
        "mcp/git"
      ]
    }
  }
}
```

## Gemini CLI Commands

### Essential MCP Commands

Once configured, use these commands within Gemini CLI:

```bash
# List configured MCP servers and their status
/mcp

# Display available tools from all MCP servers
/tools

# Show memory and session statistics
/stats

# Clear conversation memory
/memory

# Quit and restart to apply new MCP configurations
/quit
```

### Usage Examples

After configuration, you can use natural language to interact with your MCP servers:

```
# GitHub operations
"Check the latest issues in my repository"
"Create a new branch called feature/user-auth"
"Review the pull request #123"

# File operations
"Read the contents of my project's README.md"
"Create a new Python file with a Flask app"
"List all JavaScript files in the src directory"

# Database operations
"Show me the schema of the users table"
"Create a new migration for adding email verification"
```

## Security Considerations

### Environment Variables

Store sensitive information in environment variables:

```bash
# Set environment variables
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token"
export DATABASE_URL="postgresql://user:pass@localhost/db"

# Reference in settings.json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token"
      }
    }
  }
}
```

### Trust Settings

⚠️ **Important Security Note**: MCP servers can run arbitrary code with your user account permissions. Only use servers from trusted sources.

Consider using Docker containers to limit access:
- File system access
- Network permissions
- Environment variables

## Verification and Testing

### 1. Check Configuration

After editing `~/.gemini/settings.json`:

```bash
# Quit Gemini CLI
/quit

# Restart Gemini CLI
gemini

# Check MCP server status
/mcp
```

### 2. Test MCP Tools

```bash
# List all available tools
/tools

# The output should show tools from your configured MCP servers
```

### 3. Test Functionality

Try using each MCP server:

```
# Test GitHub MCP
"List my GitHub repositories"

# Test filesystem MCP
"What files are in my current directory?"
```

## Troubleshooting

### Common Issues

1. **MCP Server Not Listed**
   - Check JSON syntax in settings.json
   - Verify command paths and arguments
   - Restart Gemini CLI after configuration changes

2. **Authentication Errors**
   - Verify API tokens and credentials
   - Check environment variable names
   - Ensure tokens have proper scopes

3. **Permission Denied**
   - Check file/directory permissions
   - Verify Docker is running (for Docker-based servers)
   - Ensure network access for remote services

4. **NPX Package Not Found**
   - Update Node.js and npm
   - Clear npm cache: `npm cache clean --force`
   - Try global installation first

### Debug Tips

1. **Check Settings Format**:
   ```bash
   # Validate JSON syntax
   python -m json.tool ~/.gemini/settings.json
   ```

2. **Test Commands Manually**:
   ```bash
   # Test the exact command from settings.json
   npx -y @modelcontextprotocol/server-github
   ```

3. **Environment Variables**:
   ```bash
   # Check if environment variables are set
   echo $GITHUB_PERSONAL_ACCESS_TOKEN
   ```

## Integration with Context Framework

### Project-Specific Configuration

Create project-specific MCP configurations by:

1. **Local Settings**: Copy global settings to project-specific location
2. **Environment Files**: Use `.env` files for project-specific tokens
3. **Documentation Access**: Configure filesystem MCP to access your docs folder

### Example Project Setup

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "your_token"
      }
    },
    "project-files": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./docs", "./src", "./tests"]
    },
    "database": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "DATABASE_URL": "postgresql://localhost/myproject"
      }
    }
  }
}
```

## VS Code Integration

Gemini Code Assist in VS Code is powered by Gemini CLI and supports:
- Model Context Protocol (MCP) servers
- Gemini CLI commands (`/memory`, `/stats`, `/tools`, `/mcp`)
- Built-in tools (grep, terminal, file operations)
- Web search and web fetch capabilities

Configure MCP servers in your Gemini CLI settings, and they'll be available in VS Code as well.

## Best Practices

1. **Start Simple**: Begin with GitHub and filesystem MCP servers
2. **Secure Configuration**: Use environment variables for sensitive data
3. **Regular Updates**: Keep MCP server packages updated
4. **Monitor Usage**: Use `/stats` to monitor resource usage
5. **Documentation**: Document your MCP server configurations in your project

## Use Cases Aligned with Your Context Framework

With Gemini CLI and properly configured MCP servers, you can:

1. **Automated Context Loading**: "Read all ADRs in my docs folder and summarize the key architectural decisions"

2. **Code Generation with Context**: "Create a new API endpoint following the patterns in existing controllers"

3. **Documentation Maintenance**: "Update the user story US-001 based on the recent implementation in GitHub PR #45"

4. **Database Operations**: "Generate migration scripts based on the Pydantic models in my project"

5. **Multi-step Workflows**: "Create a new feature branch, implement JWT authentication following ADR-003, write tests, and create a pull request"

## Next Steps

After configuring Gemini CLI with MCP servers:

1. Test basic functionality with simple commands
2. Create project-specific configurations
3. Integrate with your existing context documentation
4. Experiment with complex multi-step workflows
5. Consider additional MCP servers for specialized tasks

For Claude Code setup, see the [Claude Code Setup Guide](./claude-code-setup.md).