"""
Pydantic Models for AI Agent Context Management

These models define the data structures used for managing AI agent context,
implementing the structured context framework described in ADR-001.
They ensure type safety and validation for all context-related operations.
"""

from datetime import datetime
from typing import List, Optional, Dict, Any, Literal
from enum import Enum
from pydantic import BaseModel, Field, HttpUrl, validator, ConfigDict
from uuid import UUID, uuid4


class ContextType(str, Enum):
    """Types of context documents supported by the system"""
    ADR = "ADR"
    USER_STORY = "USER_STORY"
    OPENAPI = "OPENAPI"
    SCHEMA = "SCHEMA"
    PYDANTIC = "PYDANTIC"
    README = "README"
    CLAUDE_MD = "CLAUDE_MD"


class MCPServerType(str, Enum):
    """Types of MCP servers"""
    LOCAL = "LOCAL"
    REMOTE = "REMOTE"
    DOCKER = "DOCKER"


class TrustLevel(str, Enum):
    """Trust levels for MCP servers"""
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    MAXIMUM = "MAXIMUM"


class AgentPhase(str, Enum):
    """Phases in the Plan-Propose-Proceed pattern"""
    PLAN = "PLAN"
    PROPOSE = "PROPOSE"
    PROCEED = "PROCEED"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"


class ContextDocument(BaseModel):
    """
    Represents a single context document that provides information to AI agents.
    This could be an ADR, user story, schema, or any other structured documentation.
    """
    model_config = ConfigDict(use_enum_values=True)
    
    id: UUID = Field(default_factory=uuid4)
    type: ContextType
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1)
    file_path: Optional[str] = None
    tokens: int = Field(0, ge=0, description="Number of tokens in the content")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    version: str = Field("1.0.0", pattern=r"^\d+\.\d+\.\d+$")
    metadata: Dict[str, Any] = Field(default_factory=dict)
    
    @validator('tokens', pre=False, always=True)
    def calculate_tokens(cls, v, values):
        """Estimate token count if not provided"""
        if v == 0 and 'content' in values:
            # Rough estimation: 1 token ≈ 4 characters
            return len(values['content']) // 4
        return v


class ProjectContext(BaseModel):
    """
    Complete context for a project, containing all documents needed
    to brief an AI agent about the project.
    """
    model_config = ConfigDict(use_enum_values=True)
    
    id: UUID = Field(default_factory=uuid4)
    project_name: str
    project_path: str
    documents: List[ContextDocument] = Field(default_factory=list)
    total_tokens: int = Field(0, ge=0)
    max_tokens: int = Field(100000, ge=1000)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_updated: datetime = Field(default_factory=datetime.utcnow)
    
    @validator('total_tokens', pre=False, always=True)
    def calculate_total_tokens(cls, v, values):
        """Calculate total tokens from all documents"""
        if 'documents' in values:
            return sum(doc.tokens for doc in values['documents'])
        return v
    
    def add_document(self, document: ContextDocument) -> bool:
        """Add a document if it fits within token limits"""
        if self.total_tokens + document.tokens <= self.max_tokens:
            self.documents.append(document)
            self.total_tokens += document.tokens
            self.last_updated = datetime.utcnow()
            return True
        return False
    
    def get_documents_by_type(self, doc_type: ContextType) -> List[ContextDocument]:
        """Filter documents by type"""
        return [doc for doc in self.documents if doc.type == doc_type]


class MCPServerConfig(BaseModel):
    """Configuration for an MCP server"""
    model_config = ConfigDict(use_enum_values=True)
    
    name: str = Field(..., min_length=1, max_length=50)
    type: MCPServerType
    trust_level: TrustLevel
    command: str
    args: List[str] = Field(default_factory=list)
    env: Dict[str, str] = Field(default_factory=dict)
    transport: Literal["stdio", "http", "sse"] = "stdio"
    endpoint: Optional[HttpUrl] = None
    authentication: Optional[Dict[str, str]] = Field(default_factory=dict)
    description: str = Field("", max_length=500)
    enabled: bool = True
    
    @validator('endpoint')
    def validate_endpoint(cls, v, values):
        """Ensure remote servers have endpoints"""
        if values.get('type') == MCPServerType.REMOTE and not v:
            raise ValueError("Remote MCP servers must have an endpoint")
        return v


class AgentTask(BaseModel):
    """Represents a task for an AI agent to perform"""
    model_config = ConfigDict(use_enum_values=True)
    
    id: UUID = Field(default_factory=uuid4)
    description: str = Field(..., min_length=1, max_length=1000)
    context_id: UUID
    constraints: List[str] = Field(default_factory=list)
    tools_required: List[str] = Field(default_factory=list)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    status: Literal["pending", "in_progress", "completed", "failed"] = "pending"
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            UUID: lambda v: str(v)
        }


class ExecutionPlan(BaseModel):
    """Plan generated in the Plan phase of Plan-Propose-Proceed"""
    model_config = ConfigDict(use_enum_values=True)
    
    id: UUID = Field(default_factory=uuid4)
    task_id: UUID
    steps: List[Dict[str, Any]]
    estimated_time_seconds: int = Field(0, ge=0)
    risk_assessment: Literal["LOW", "MEDIUM", "HIGH"]
    created_at: datetime = Field(default_factory=datetime.utcnow)
    approved: bool = False
    approval_token: Optional[str] = None


class ChangeProposal(BaseModel):
    """Proposal for changes in the Propose phase"""
    
    id: UUID = Field(default_factory=uuid4)
    plan_id: UUID
    changes: List[Dict[str, Any]]
    requires_approval: bool = True
    preview_available: bool = True
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ExecutionResult(BaseModel):
    """Result of executing an approved plan in the Proceed phase"""
    model_config = ConfigDict(use_enum_values=True)
    
    id: UUID = Field(default_factory=uuid4)
    proposal_id: UUID
    status: Literal["SUCCESS", "PARTIAL", "FAILED"]
    results: List[Dict[str, Any]]
    execution_time_seconds: float = Field(0.0, ge=0.0)
    completed_at: datetime = Field(default_factory=datetime.utcnow)
    error_message: Optional[str] = None


class AgentSession(BaseModel):
    """Represents an AI agent session with context and history"""
    
    id: UUID = Field(default_factory=uuid4)
    context: ProjectContext
    mcp_servers: List[MCPServerConfig] = Field(default_factory=list)
    current_task: Optional[AgentTask] = None
    current_phase: Optional[AgentPhase] = None
    execution_history: List[ExecutionResult] = Field(default_factory=list)
    started_at: datetime = Field(default_factory=datetime.utcnow)
    last_activity: datetime = Field(default_factory=datetime.utcnow)
    tools_executed_count: int = 0
    
    def add_mcp_server(self, config: MCPServerConfig) -> None:
        """Add an MCP server to the session"""
        self.mcp_servers.append(config)
        self.last_activity = datetime.utcnow()
    
    def update_phase(self, phase: AgentPhase) -> None:
        """Update the current phase in the workflow"""
        self.current_phase = phase
        self.last_activity = datetime.utcnow()


class ToolDefinition(BaseModel):
    """Definition of an MCP tool available to the agent"""
    
    name: str = Field(..., min_length=1, max_length=100)
    description: str = Field(..., max_length=500)
    parameters: List[Dict[str, Any]] = Field(default_factory=list)
    server_name: str
    requires_confirmation: bool = False
    trust_level: TrustLevel


class ToolExecutionRequest(BaseModel):
    """Request to execute an MCP tool"""
    
    tool_name: str
    parameters: Dict[str, Any] = Field(default_factory=dict)
    session_id: UUID
    dry_run: bool = False


class ToolExecutionResponse(BaseModel):
    """Response from executing an MCP tool"""
    
    success: bool
    result: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    execution_time: float = Field(0.0, ge=0.0)
    timestamp: datetime = Field(default_factory=datetime.utcnow)


# Validation Models for API Requests/Responses

class ContextLoadRequest(BaseModel):
    """Request to load project context"""
    
    project_path: str
    context_types: List[ContextType] = Field(default_factory=lambda: list(ContextType))
    max_tokens: int = Field(100000, ge=1000, le=1000000)


class ContextValidationResult(BaseModel):
    """Result of context validation"""
    
    valid: bool
    missing_types: List[ContextType] = Field(default_factory=list)
    issues: List[Dict[str, str]] = Field(default_factory=list)
    recommendations: List[str] = Field(default_factory=list)


# Example usage and helper functions

def create_context_from_directory(directory_path: str) -> ProjectContext:
    """
    Helper function to create a ProjectContext from a documentation directory.
    This would scan the directory and load all context documents.
    """
    # This is a mock implementation for demonstration
    context = ProjectContext(
        project_name="Example Project",
        project_path=directory_path,
        max_tokens=100000
    )
    
    # Example ADR document
    adr = ContextDocument(
        type=ContextType.ADR,
        title="ADR-001: LLM Context Architecture",
        content="# ADR-001\n\nContent of the ADR...",
        file_path=f"{directory_path}/adr/adr-001.md"
    )
    context.add_document(adr)
    
    return context


def validate_context_completeness(context: ProjectContext) -> ContextValidationResult:
    """
    Validate that a project context contains all required document types.
    """
    required_types = [ContextType.ADR, ContextType.USER_STORY, ContextType.OPENAPI]
    present_types = set(doc.type for doc in context.documents)
    missing_types = [t for t in required_types if t not in present_types]
    
    issues = []
    if missing_types:
        issues.append({
            "severity": "ERROR",
            "message": f"Missing required document types: {missing_types}"
        })
    
    if context.total_tokens > context.max_tokens:
        issues.append({
            "severity": "WARNING",
            "message": f"Context exceeds token limit: {context.total_tokens}/{context.max_tokens}"
        })
    
    return ContextValidationResult(
        valid=len(missing_types) == 0,
        missing_types=missing_types,
        issues=issues,
        recommendations=[
            "Consider adding more ADRs to document architectural decisions",
            "Ensure all API endpoints have OpenAPI specifications"
        ] if missing_types else []
    )