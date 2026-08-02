#!/usr/bin/env bash
#
# setup-worktree-repo.sh
# Interactive generator for a progressive multi-stage Git repository with:
#  1. Sequential feature branches (stage 1 -> stage 2 -> ... -> stage N)
#  2. Local Git Worktrees for live demos (.worktrees/stage-X)
#  3. GitHub repository creation and Comparison Pull Requests via GitHub CLI (gh)
#

set -euo pipefail

echo "================================================================"
echo "🎯 Interactive Progressive Course Repository Generator"
echo "================================================================"
echo ""

# ==============================================================================
# 1. INTERACTIVE QUESTIONS
# ==============================================================================

# Question 1: Project Name
read -p "1️⃣  What should I name the project directory? [default: adk-progressive-agent-course]: " REPO_NAME
REPO_NAME="${REPO_NAME:-adk-progressive-agent-course}"

# Question 2: Number of Stages
read -p "2️⃣  How many stages will there be for demoing? [default: 4]: " NUM_STAGES
NUM_STAGES="${NUM_STAGES:-4}"

# Validate NUM_STAGES is a positive integer
if ! [[ "$NUM_STAGES" =~ ^[1-9][0-9]*$ ]]; then
  echo "❌ Number of stages must be a positive number. Exiting."
  exit 1
fi

# Default branch names for up to 4 stages
DEFAULT_BRANCHES=(
  "stage-1-basic-agent"
  "stage-2-rag-agent"
  "stage-3-multi-agent"
  "stage-4-sdlc-production"
)

STAGE_BRANCHES=()
echo ""
echo "📌 Specify branch names for each of the ${NUM_STAGES} stages:"
for (( i=1; i<=NUM_STAGES; i++ )); do
  idx=$((i - 1))
  default_branch="${DEFAULT_BRANCHES[$idx]:-stage-${i}}"
  read -p "   Branch name for Stage ${i} [default: ${default_branch}]: " branch_name
  branch_name="${branch_name:-$default_branch}"
  STAGE_BRANCHES+=("$branch_name")
done

# Question 3: Remote Repository
DEFAULT_REMOTE="${REPO_NAME}"
read -p "3️⃣  What remote GitHub repository should I create for tracking? (e.g. 'repo-name' or 'owner/repo') [default: ${DEFAULT_REMOTE}]: " GITHUB_REMOTE
GITHUB_REMOTE="${GITHUB_REMOTE:-$DEFAULT_REMOTE}"

read -p "   Should the remote repository be public or private? [public/private, default: public]: " VISIBILITY_INPUT
VISIBILITY_INPUT="${VISIBILITY_INPUT:-public}"
if [[ "$VISIBILITY_INPUT" =~ ^priv ]]; then
  REPO_VISIBILITY="--private"
else
  REPO_VISIBILITY="--public"
fi

# Summary confirmation
echo ""
echo "================================================================"
echo "📋 Summary of Course Repository Setup"
echo "================================================================"
echo "   • Project Directory : ${REPO_NAME}"
echo "   • Number of Stages  : ${NUM_STAGES}"
echo "   • Branches          : ${STAGE_BRANCHES[*]}"
echo "   • GitHub Remote     : ${GITHUB_REMOTE} (${VISIBILITY_INPUT})"
echo "================================================================"
read -p "▶️  Proceed with scaffolding and GitHub repository setup? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "🛑 Setup canceled."
  exit 0
fi

# ==============================================================================
# 2. INITIALIZE ROOT REPOSITORY
# ==============================================================================
MAIN_BRANCH="main"

echo ""
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
.trajectory_state.json
GITIGNORE_EOF

# Create initial README
cat << README_EOF > README.md
# ${REPO_NAME}

A progressive ${NUM_STAGES}-stage application build demonstrating step-by-step development:

README_EOF

for (( i=0; i<NUM_STAGES; i++ )); do
  stage_num=$((i + 1))
  echo "${stage_num}. **Stage ${stage_num}**: \`${STAGE_BRANCHES[$i]}\`" >> README.md
done

git add .
git commit -m "chore: initial project setup and README"

# ==============================================================================
# 3. CREATE PROGRESSIVE BRANCHES
# ==============================================================================
echo "🌱 Creating sequential feature branches..."
for (( i=0; i<NUM_STAGES; i++ )); do
  stage_num=$((i + 1))
  branch="${STAGE_BRANCHES[$i]}"
  git checkout -b "$branch"
  git commit --allow-empty -m "feat: stage ${stage_num} - ${branch}"
done

# Return to main branch in root directory
git checkout "${MAIN_BRANCH}"

# ==============================================================================
# 4. SET UP LOCAL WORKTREES FOR LIVE DEMOS
# ==============================================================================
echo "🌲 Setting up local Git Worktrees in '.worktrees/'..."
mkdir -p .worktrees

for (( i=0; i<NUM_STAGES; i++ )); do
  stage_num=$((i + 1))
  branch="${STAGE_BRANCHES[$i]}"
  git worktree add ".worktrees/stage-${stage_num}" "$branch"
done

echo "✅ Worktrees created successfully!"

# ==============================================================================
# 5. CREATE GITHUB REPOSITORY & COMPARISON PRs
# ==============================================================================
if command -v gh &> /dev/null; then
  echo "🌐 Creating GitHub repository '${GITHUB_REMOTE}' via GitHub CLI..."
  
  gh repo create "${GITHUB_REMOTE}" ${REPO_VISIBILITY} --source=. --remote=origin --push
  
  echo "⬆️  Pushing progressive branches to GitHub..."
  for (( i=0; i<NUM_STAGES; i++ )); do
    branch="${STAGE_BRANCHES[$i]}"
    git push -u origin "$branch"
  done

  if (( NUM_STAGES > 1 )); then
    echo "🔀 Creating GitHub Comparison Pull Requests..."
    for (( i=0; i<NUM_STAGES-1; i++ )); do
      base_branch="${STAGE_BRANCHES[$i]}"
      head_branch="${STAGE_BRANCHES[$i+1]}"
      stage_from=$((i + 1))
      stage_to=$((i + 2))

      gh pr create \
        --base "$base_branch" \
        --head "$head_branch" \
        --title "Stage ${stage_to}: Upgrade from ${base_branch} to ${head_branch}" \
        --body "Comparison PR showing the exact diff from **Stage ${stage_from} (${base_branch})** to **Stage ${stage_to} (${head_branch})**."
    done
  fi

  echo "🎉 Repository, worktrees, and comparison PRs are ready!"
else
  echo "⚠️  GitHub CLI ('gh') not found. Skipped pushing to GitHub and PR creation."
  echo "   Install 'gh' from https://cli.github.com to automate GitHub repo & PR creation."
fi
