---
name: record-trajectory
description: Automatically records the user's prompt trajectory, context, and code impacts into structured markdown files (trajectories/stage_X.md) as they build a project. Supports start, pause, resume, and stop commands, and automatically commits and pushes when stopped.
---

# Record Trajectory Skill

You are equipped with the `record-trajectory` skill. Your job is to document the user's development journey so it can be replayed later for educational demonstrations.

## State Management
You maintain recording state in a local file at the repository root: `.trajectory_state.json`.
Do NOT commit `.trajectory_state.json` to git (ensure it is listed in `.gitignore`).

### Schema of `.trajectory_state.json`:
```json
{
  "stage_name": "stage_1",
  "status": "recording",  // "recording", "paused", or "stopped"
  "step_count": 0,
  "file_path": "trajectories/stage_1.md"
}
```

---

## Supported Commands & Behaviors

### 1. START (`"start recording trajectory for <stage_name>"`)
When the user asks to start recording a trajectory:
1. Ensure the `trajectories/` directory exists.
2. Initialize or open `trajectories/<stage_name>.md`. If new, write the title header:
   ```markdown
   # <stage_name> - Trajectory
   ```
3. Create/update `.trajectory_state.json` with `"stage_name": "<stage_name>"`, `"status": "recording"`, and `"step_count": 0` (or the last recorded step number if appending to an existing file).
4. Confirm to the user: *"🎯 Trajectory recording started for `<stage_name>` in `trajectories/<stage_name>.md`."*

---

### 2. DURING ACTIVE RECORDING (`status == "recording"`)
Whenever `.trajectory_state.json` exists and `"status"` is `"recording"`, after you fulfill **any** user coding prompt:
1. Increment `"step_count"` in `.trajectory_state.json`.
2. Append a formatted step block to `trajectories/<stage_name>.md`:
   ```markdown

   ## Trajectory Step <step_count>: <Short Title Summarizing Goal>
   - **Goal**: <1-2 sentence summary of what the user asked to achieve>
   - **Context**: <List of key files read, created, or modified>
   - **Prompt**:
     ```text
     <The exact prompt text the user sent>
     ```
   - **Expected Impact**: <Brief description of the code changes, new functions, or architecture additions generated>
   ```
3. In your response to the user, include a brief footnote: *"📝 (Recorded as Trajectory Step `<step_count>` in `trajectories/<stage_name>.md`)"*.

---

### 3. PAUSE (`"pause trajectory recording"`)
When the user asks to pause:
1. Update `.trajectory_state.json` to `"status": "paused"`.
2. Confirm to the user: *"⏸️ Trajectory recording paused. Your prompts will not be recorded until you say 'resume trajectory recording'."*

---

### 4. RESUME (`"resume trajectory recording"`)
When the user asks to resume:
1. Update `.trajectory_state.json` to `"status": "recording"`.
2. Confirm to the user: *"▶️ Trajectory recording resumed for `<stage_name>`."*

---

### 5. STOP & COMMIT (`"stop trajectory recording"`)
When the user asks to stop recording:
1. Set `"status": "stopped"` and remove `.trajectory_state.json`.
2. Ensure `trajectories/<stage_name>.md` is saved.
3. Stage and commit the trajectory file using Git:
   ```bash
   git add trajectories/<stage_name>.md
   git commit -m "docs(trajectory): finalize development trajectory for <stage_name>"
   ```
4. Push the commit to the current remote branch:
   ```bash
   git push origin HEAD
   ```
5. Confirm to the user: *"✅ Trajectory recording stopped. Formatted trajectory saved to `trajectories/<stage_name>.md`, committed, and pushed to `origin`!"*
