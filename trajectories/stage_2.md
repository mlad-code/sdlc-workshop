# Stage 2: RAG & Knowledge Grounding - Trajectory

## Trajectory Step 1: Adding Vector Retrieval Tool
- **Goal**: Give the agent access to a document retrieval tool.
- **Context**: `src/tools.py`, `src/agent.py`
- **Prompt**:
  ```text
  Implement a document retrieval tool in src/retrieval.py that searches over a knowledge base using vector similarity. Connect this tool to src/agent.py and update the agent's system instructions to always cite its sources when answering domain questions.
  ```
- **Expected Impact**: Generates `src/retrieval.py` and updates prompt instructions in `src/agent.py`.
