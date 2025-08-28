-- AI Agent Context Management Database Schema
-- This schema supports the structured context framework described in ADR-001
-- and implements persistent storage for the Plan-Propose-Proceed pattern.

-- Enable UUID extension for PostgreSQL
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum types for better data integrity
CREATE TYPE context_type AS ENUM (
    'ADR', 
    'USER_STORY', 
    'OPENAPI', 
    'SCHEMA', 
    'PYDANTIC', 
    'README', 
    'CLAUDE_MD'
);

CREATE TYPE mcp_server_type AS ENUM (
    'LOCAL', 
    'REMOTE', 
    'DOCKER'
);

CREATE TYPE trust_level AS ENUM (
    'LOW', 
    'MEDIUM', 
    'HIGH', 
    'MAXIMUM'
);

CREATE TYPE transport_type AS ENUM (
    'stdio', 
    'http', 
    'sse'
);

CREATE TYPE agent_phase AS ENUM (
    'PLAN', 
    'PROPOSE', 
    'PROCEED', 
    'COMPLETED', 
    'FAILED'
);

CREATE TYPE task_status AS ENUM (
    'pending', 
    'in_progress', 
    'completed', 
    'failed'
);

CREATE TYPE execution_status AS ENUM (
    'SUCCESS', 
    'PARTIAL', 
    'FAILED'
);

CREATE TYPE session_status AS ENUM (
    'ACTIVE', 
    'IDLE', 
    'COMPLETED', 
    'ERROR'
);

-- Project contexts table - represents complete context for a project
CREATE TABLE project_contexts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_name VARCHAR(200) NOT NULL,
    project_path TEXT NOT NULL,
    total_tokens INTEGER DEFAULT 0 CHECK (total_tokens >= 0),
    max_tokens INTEGER DEFAULT 100000 CHECK (max_tokens > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    
    -- Indexes for performance
    CONSTRAINT unique_project_path UNIQUE (project_path)
);

-- Context documents table - individual documents that provide context
CREATE TABLE context_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_context_id UUID NOT NULL REFERENCES project_contexts(id) ON DELETE CASCADE,
    type context_type NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    file_path TEXT,
    tokens INTEGER DEFAULT 0 CHECK (tokens >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    version VARCHAR(20) DEFAULT '1.0.0',
    metadata JSONB DEFAULT '{}',
    
    -- Indexes for performance
    CONSTRAINT check_title_length CHECK (LENGTH(title) > 0),
    CONSTRAINT check_content_length CHECK (LENGTH(content) > 0)
);

-- MCP server configurations table
CREATE TABLE mcp_server_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(50) NOT NULL UNIQUE,
    type mcp_server_type NOT NULL,
    trust_level trust_level NOT NULL,
    command VARCHAR(500) NOT NULL,
    args TEXT[], -- Array of command arguments
    env JSONB DEFAULT '{}', -- Environment variables as JSON
    transport transport_type DEFAULT 'stdio',
    endpoint TEXT, -- URL for remote servers
    authentication JSONB DEFAULT '{}', -- Auth config as JSON
    description TEXT DEFAULT '',
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    CONSTRAINT check_remote_endpoint CHECK (
        (type != 'REMOTE') OR (endpoint IS NOT NULL)
    ),
    CONSTRAINT check_name_length CHECK (LENGTH(name) > 0)
);

-- Agent sessions table - tracks AI agent sessions
CREATE TABLE agent_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_context_id UUID NOT NULL REFERENCES project_contexts(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    tools_executed_count INTEGER DEFAULT 0 CHECK (tools_executed_count >= 0),
    status session_status DEFAULT 'ACTIVE',
    metadata JSONB DEFAULT '{}'
);

-- Agent tasks table - tracks tasks assigned to AI agents
CREATE TABLE agent_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES agent_sessions(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    constraints TEXT[], -- Array of constraint strings
    tools_required TEXT[], -- Array of required tool names
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status task_status DEFAULT 'pending',
    
    CONSTRAINT check_description_length CHECK (LENGTH(description) > 0)
);

-- Execution plans table - Plans generated in the Plan phase
CREATE TABLE execution_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES agent_tasks(id) ON DELETE CASCADE,
    steps JSONB NOT NULL, -- Array of step objects
    estimated_time_seconds INTEGER DEFAULT 0 CHECK (estimated_time_seconds >= 0),
    risk_assessment trust_level NOT NULL, -- Using trust_level enum for LOW/MEDIUM/HIGH
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    approved BOOLEAN DEFAULT false,
    approval_token VARCHAR(100),
    approved_at TIMESTAMP WITH TIME ZONE,
    approved_by VARCHAR(100) -- User who approved the plan
);

-- Change proposals table - Proposals in the Propose phase
CREATE TABLE change_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES execution_plans(id) ON DELETE CASCADE,
    changes JSONB NOT NULL, -- Array of change objects
    requires_approval BOOLEAN DEFAULT true,
    preview_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    preview_data JSONB DEFAULT '{}'
);

-- Execution results table - Results from the Proceed phase
CREATE TABLE execution_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES change_proposals(id) ON DELETE CASCADE,
    status execution_status NOT NULL,
    results JSONB NOT NULL, -- Array of result objects
    execution_time_seconds DECIMAL(10,3) DEFAULT 0.0 CHECK (execution_time_seconds >= 0),
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    error_message TEXT,
    logs JSONB DEFAULT '[]' -- Array of log entries
);

-- Session MCP servers junction table - tracks which MCP servers are active in a session
CREATE TABLE session_mcp_servers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES agent_sessions(id) ON DELETE CASCADE,
    server_config_id UUID NOT NULL REFERENCES mcp_server_configs(id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    usage_count INTEGER DEFAULT 0 CHECK (usage_count >= 0),
    
    UNIQUE(session_id, server_config_id)
);

-- Tool definitions table - defines available MCP tools
CREATE TABLE tool_definitions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    parameters JSONB DEFAULT '[]', -- Array of parameter definitions
    server_config_id UUID NOT NULL REFERENCES mcp_server_configs(id) ON DELETE CASCADE,
    requires_confirmation BOOLEAN DEFAULT false,
    trust_level trust_level NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT check_tool_name_length CHECK (LENGTH(name) > 0),
    UNIQUE(name, server_config_id)
);

-- Tool executions table - logs of tool execution requests and responses
CREATE TABLE tool_executions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES agent_sessions(id) ON DELETE CASCADE,
    tool_definition_id UUID NOT NULL REFERENCES tool_definitions(id),
    parameters JSONB DEFAULT '{}',
    dry_run BOOLEAN DEFAULT false,
    success BOOLEAN,
    result JSONB,
    error_message TEXT,
    execution_time_seconds DECIMAL(10,3) DEFAULT 0.0 CHECK (execution_time_seconds >= 0),
    executed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Audit log table - tracks all significant actions for security and debugging
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID REFERENCES agent_sessions(id),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    old_values JSONB,
    new_values JSONB,
    user_id VARCHAR(100), -- Who initiated the action
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB DEFAULT '{}'
);

-- Indexes for performance optimization

-- Context documents indexes
CREATE INDEX idx_context_documents_project_id ON context_documents(project_context_id);
CREATE INDEX idx_context_documents_type ON context_documents(type);
CREATE INDEX idx_context_documents_updated_at ON context_documents(updated_at);

-- Agent sessions indexes
CREATE INDEX idx_agent_sessions_project_context ON agent_sessions(project_context_id);
CREATE INDEX idx_agent_sessions_status ON agent_sessions(status);
CREATE INDEX idx_agent_sessions_last_activity ON agent_sessions(last_activity);

-- Agent tasks indexes
CREATE INDEX idx_agent_tasks_session_id ON agent_tasks(session_id);
CREATE INDEX idx_agent_tasks_status ON agent_tasks(status);
CREATE INDEX idx_agent_tasks_created_at ON agent_tasks(created_at);

-- Tool executions indexes for performance monitoring
CREATE INDEX idx_tool_executions_session_id ON tool_executions(session_id);
CREATE INDEX idx_tool_executions_executed_at ON tool_executions(executed_at);
CREATE INDEX idx_tool_executions_tool_id ON tool_executions(tool_definition_id);

-- Audit log indexes
CREATE INDEX idx_audit_log_session_id ON audit_log(session_id);
CREATE INDEX idx_audit_log_timestamp ON audit_log(timestamp);
CREATE INDEX idx_audit_log_action ON audit_log(action);

-- Full-text search indexes for content search
CREATE INDEX idx_context_documents_content_fts ON context_documents 
USING gin(to_tsvector('english', content));

CREATE INDEX idx_context_documents_title_fts ON context_documents 
USING gin(to_tsvector('english', title));

-- Triggers for maintaining timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_project_contexts_updated_at
    BEFORE UPDATE ON project_contexts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_context_documents_updated_at
    BEFORE UPDATE ON context_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mcp_server_configs_updated_at
    BEFORE UPDATE ON mcp_server_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_tasks_updated_at
    BEFORE UPDATE ON agent_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tool_definitions_updated_at
    BEFORE UPDATE ON tool_definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to automatically update total_tokens in project_contexts
CREATE OR REPLACE FUNCTION update_project_context_tokens()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_tokens for the affected project context
    UPDATE project_contexts 
    SET total_tokens = (
        SELECT COALESCE(SUM(tokens), 0)
        FROM context_documents 
        WHERE project_context_id = COALESCE(NEW.project_context_id, OLD.project_context_id)
    ),
    last_updated = CURRENT_TIMESTAMP
    WHERE id = COALESCE(NEW.project_context_id, OLD.project_context_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ language 'plpgsql';

CREATE TRIGGER update_context_tokens
    AFTER INSERT OR UPDATE OR DELETE ON context_documents
    FOR EACH ROW EXECUTE FUNCTION update_project_context_tokens();

-- Sample data for demonstration
INSERT INTO project_contexts (project_name, project_path, max_tokens) VALUES
('Agentic CLI Demo', '/Users/example/projects/agentic-cli', 150000);

-- Get the inserted project context ID
DO $$
DECLARE
    project_id UUID;
BEGIN
    SELECT id INTO project_id FROM project_contexts WHERE project_name = 'Agentic CLI Demo';
    
    -- Sample context documents
    INSERT INTO context_documents (project_context_id, type, title, content, tokens) VALUES
    (project_id, 'ADR', 'ADR-001: LLM Context Architecture', 
     'Decision about structured context for LLMs...', 2500),
    (project_id, 'USER_STORY', 'US-001: AI Agent Context Management', 
     'As a developer, I want automated context loading...', 1800),
    (project_id, 'OPENAPI', 'MCP Server API Specification', 
     'OpenAPI 3.0 specification for MCP server...', 5000);
END $$;

-- Sample MCP server configurations
INSERT INTO mcp_server_configs (name, type, trust_level, command, args, description) VALUES
('context7', 'REMOTE', 'MEDIUM', 'npx', 
 ARRAY['-y', '@upstash/context7-mcp', '--api-key', 'YOUR_API_KEY'], 
 'Context7 MCP server for up-to-date documentation'),
('github', 'DOCKER', 'HIGH', 'docker', 
 ARRAY['run', '-i', '--rm', '-e', 'GITHUB_PERSONAL_ACCESS_TOKEN', 'ghcr.io/github/github-mcp-server'], 
 'GitHub MCP server for repository operations'),
('filesystem', 'LOCAL', 'MAXIMUM', 'npx', 
 ARRAY['-y', '@modelcontextprotocol/server-filesystem'], 
 'Local filesystem access server');

-- Comments for documentation
COMMENT ON TABLE project_contexts IS 'Stores complete context information for AI agent projects';
COMMENT ON TABLE context_documents IS 'Individual context documents (ADRs, user stories, schemas, etc.)';
COMMENT ON TABLE mcp_server_configs IS 'Configuration for Model Context Protocol servers';
COMMENT ON TABLE agent_sessions IS 'Active AI agent sessions with context and history';
COMMENT ON TABLE agent_tasks IS 'Tasks assigned to AI agents for completion';
COMMENT ON TABLE execution_plans IS 'Plans generated in the Plan phase of Plan-Propose-Proceed';
COMMENT ON TABLE change_proposals IS 'Change proposals in the Propose phase';
COMMENT ON TABLE execution_results IS 'Results from executing approved plans in the Proceed phase';
COMMENT ON TABLE tool_executions IS 'Log of all MCP tool executions for monitoring and debugging';
COMMENT ON TABLE audit_log IS 'Comprehensive audit trail for security and compliance';