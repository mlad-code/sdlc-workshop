#!/usr/bin/env bash
#
# walk-trajectories.sh
# Interactive trajectory walkthrough tool for agentic coding demonstrations.
# Usage: ./walk-trajectories.sh trajectories/stage_1.md [--commit]
#

set -euo pipefail

TRAJECTORY_FILE="${1:-}"
AUTO_COMMIT=false

if [[ -z "${TRAJECTORY_FILE}" ]] || [[ ! -f "${TRAJECTORY_FILE}" ]]; then
  echo "Usage: $0 <path-to-trajectory-markdown-file> [--commit]"
  echo "Example: $0 trajectories/stage_1.md --commit"
  exit 1
fi

if [[ "${2:-}" == "--commit" ]]; then
  AUTO_COMMIT=true
fi

echo "================================================================"
echo "🎯 Interactive Trajectory Walkthrough: ${TRAJECTORY_FILE}"
echo "================================================================"

STEP_NUM=0

while IFS= read -r line; do
  if [[ "$line" =~ ^##\ (Trajectory\ Step[^\$]+) ]]; then
    STEP_TITLE="${BASH_REMATCH[1]}"
    STEP_NUM=$((STEP_NUM + 1))
    echo ""
    echo "----------------------------------------------------------------"
    echo "📌 STEP ${STEP_NUM}: ${STEP_TITLE}"
    echo "----------------------------------------------------------------"
  elif [[ "$line" =~ ^\-\ \*\*Goal\*\*:\ (.*) ]]; then
    echo "🎯 Goal: ${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^\-\ \*\*Context\*\*:\ (.*) ]]; then
    echo "📂 Context/Files: ${BASH_REMATCH[1]}"
  elif [[ "$line" == *'```text'* ]]; read -r PROMPT_TEXT; then
    FULL_PROMPT=""
    while IFS= read -r p_line && [[ "$p_line" != *'```'* ]]; do
      FULL_PROMPT="${FULL_PROMPT}${p_line}"$'\n'
    done
    
    echo ""
    echo "💬 PROMPT TEXT:"
    echo -e "\033[1;36m${FULL_PROMPT}\033[0m"
    
    if command -v pbcopy &> /dev/null; then
      echo -n "${FULL_PROMPT}" | pbcopy
      echo "📋 (Copied prompt to your macOS clipboard! Ready to paste into your coding harness)"
    fi
    
    echo ""
    read -p "▶️  Press [ENTER] after running this step in your harness to continue..." _
    
    if [[ "${AUTO_COMMIT}" == "true" ]]; then
      echo "💾 Creating git commit checkpoint..."
      git add .
      git commit -m "docs(trajectory): step ${STEP_NUM} - ${STEP_TITLE}" || echo "   (No changes to commit)"
    fi
  fi
done < "${TRAJECTORY_FILE}"

echo ""
echo "🎉 Walkthrough complete for ${TRAJECTORY_FILE}!"
