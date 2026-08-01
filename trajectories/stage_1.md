# Stage 1: Basic ADK Agent - Trajectory

## Trajectory Step 1: Project Scaffold & Core Agent
- **Goal**: Initialize project metadata and define a simple ADK agent.
- **Context**: Empty repository root
- **Prompt**:
  ```text
  Scaffold a Python project for a Google Agent Development Kit (ADK) agent. Create pyproject.toml with required ADK dependencies, and implement src/agent.py with a Gemini model configuration and default system instructions.
  ```
- **Expected Impact**: Generates `pyproject.toml`, `README.md`, and `src/agent.py`.

## Trajectory Step 2: Adding a Custom Tool
- **Goal**: Add a Python function tool and attach it to the agent.
- **Context**: `src/agent.py`
- **Prompt**:
  ```text
  Create a custom Python function tool in src/tools.py that performs arithmetic calculations. Import this tool into src/agent.py and register it in the agent's tool list.
  ```
- **Expected Impact**: Generates `src/tools.py` and updates `src/agent.py`.
