#!/usr/bin/env bash
#
# setup-worktree-repo.sh
# Automates setting up a 4-stage progressive Git repository with:
#  1. Sequential feature branches (stage 1 -> stage 2 -> stage 3 -> stage 4)
#  2. Local Git Worktrees for live demos (.worktrees/stage-X)
#  3. GitHub repository creation and Comparison Pull Requests via GitHub CLI (gh)
#

set -euo pipefail

# ==============================================================================
# CONFIGURATION - Customize these for future use cases
# ==============================================================================
REPO_NAME="adk-progressive-agent-course"
REPO_VISIBILITY="--public" # Use --public or --private

# Branch names in sequential order
MAIN_BRANCH="main"
STAGE_1_BRANCH="stage-1-basic-agent"
STAGE_2_BRANCH="stage-2-rag-agent"
STAGE_3_BRANCH="stage-3-multi-agent"
STAGE_4_BRANCH="stage-4-sdlc-production"

# ==============================================================================
# 1. INITIALIZE ROOT REPOSITORY
# ==============================================================================
echo "🚀 Creating repository directory: ${REPO_NAME}..."
mkdir -p "${REPO_NAME}" && cd "${REPO_NAME}"

echo "📦 Initializing git repository on '${MAIN_BRANCH}'..."
git init -b "${MAIN_BRANCH}"

# Create root .gitignore ensuring .worktrees is never tracked
cat << 'GITIGNORE_EOF' > .gitignore
# Worktrees directory for live demos
.worktrees/

# Python / General ignores
__pycache__/
*.py[cod]
*$py.class
.env
.venv/
dist/
build/
*.egg-info/
GITIGNORE_EOF

# Create initial README
cat << README_EOF > README.md
# ${REPO_NAME}

A progressive, 4-stage application build demonstrating Google Agent Development Kit (ADK) best practices:

1. **Stage 1**: Core ADK Agent & Tools (\`${STAGE_1_BRANCH}\`)
2. **Stage 2**: RAG & Knowledge Grounding (\`${STAGE_2_BRANCH}\`)
3. **Stage 3**: Multi-Agent System Orchestration (\`${STAGE_3_BRANCH}\`)
4. **Stage 4**: Full SDLC, Evals, CI/CD & Production (\`${STAGE_4_BRANCH}\`)
README_EOF

git add .
git commit -m "chore: initial project setup and README"

# ==============================================================================
# 2. CREATE PROGRESSIVE BRANCHES
# ==============================================================================
echo "🌱 Creating sequential branches..."

# Stage 1 (branching from main)
git checkout -b "${STAGE_1_BRANCH}"
git commit --allow-empty -m "feat: stage 1 - basic ADK agent"

# Stage 2 (branching from stage 1)
git checkout -b "${STAGE_2_BRANCH}"
git commit --allow-empty -m "feat: stage 2 - RAG and knowledge grounding"

# Stage 3 (branching from stage 2)
git checkout -b "${STAGE_3_BRANCH}"
git commit --allow-empty -m "feat: stage 3 - multi-agent orchestration"

# Stage 4 (branching from stage 3)
git checkout -b "${STAGE_4_BRANCH}"
git commit --allow-empty -m "feat: stage 4 - production SDLC and DevOps"

# Return to main branch in root directory
git checkout "${MAIN_BRANCH}"

# ==============================================================================
# 3. SET UP LOCAL WORKTREES FOR LIVE DEMOS
# ==============================================================================
echo "🌲 Setting up local Git Worktrees in '.worktrees/'..."
mkdir -p .worktrees

git worktree add .worktrees/stage-1 "${STAGE_1_BRANCH}"
git worktree add .worktrees/stage-2 "${STAGE_2_BRANCH}"
git worktree add .worktrees/stage-3 "${STAGE_3_BRANCH}"
git worktree add .worktrees/stage-4 "${STAGE_4_BRANCH}"

echo "✅ Worktrees created successfully!"

# ==============================================================================
# 4. CREATE GITHUB REPOSITORY & COMPARISON PRs
# ==============================================================================
if command -v gh &> /dev/null; then
  echo "🌐 Creating GitHub repository using GitHub CLI..."
  
  # Create repo on GitHub and push all branches
  gh repo create "${REPO_NAME}" ${REPO_VISIBILITY} --source=. --remote=origin --push
  
  echo "⬆️  Pushing progressive branches to GitHub..."
  git push -u origin "${STAGE_1_BRANCH}"
  git push -u origin "${STAGE_2_BRANCH}"
  git push -u origin "${STAGE_3_BRANCH}"
  git push -u origin "${STAGE_4_BRANCH}"

  echo "🔀 Creating GitHub Comparison Pull Requests..."
  
  # PR #1: Stage 2 vs Stage 1
  gh pr create \
    --base "${STAGE_1_BRANCH}" \
    --head "${STAGE_2_BRANCH}" \
    --title "Stage 2: Adding RAG & Knowledge Grounding" \
    --body "Comparison PR showing the exact diff from **Stage 1 (Basic ADK Agent)** to **Stage 2 (RAG Agent)**."

  # PR #2: Stage 3 vs Stage 2
  gh pr create \
    --base "${STAGE_2_BRANCH}" \
    --head "${STAGE_3_BRANCH}" \
    --title "Stage 3: Evolving to a Multi-Agent Architecture" \
    --body "Comparison PR showing the exact diff from **Stage 2 (RAG Agent)** to **Stage 3 (Multi-Agent System)**."

  # PR #3: Stage 4 vs Stage 3
  gh pr create \
    --base "${STAGE_3_BRANCH}" \
    --head "${STAGE_4_BRANCH}" \
    --title "Stage 4: Production SDLC, Evals & CI/CD" \
    --body "Comparison PR showing the exact diff from **Stage 3 (Multi-Agent System)** to **Stage 4 (Full SDLC Production)**."

  echo "🎉 Repository, worktrees, and comparison PRs are ready!"
else
  echo "⚠️  GitHub CLI ('gh') not found. Skipped pushing to GitHub and PR creation."
  echo "   Install 'gh' from https://cli.github.com to automate GitHub repo & PR creation."
fi
