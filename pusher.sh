#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "❌ Please provide a commit message."
    echo "Usage: ./git_push.sh \"Your commit message\" [branch_name]"
    exit 1
fi

COMMIT_MSG="$1"
BRANCH="${2:-main}"


echo "📂 Adding .gitkeep to empty folders..."
find . -type d -empty -exec touch {}/.gitkeep \;


echo "➕ Staging files..."
git add .


echo "💾 Committing changes..."
git commit -m "$COMMIT_MSG"


echo " Pushing to branch '$BRANCH'..."
git push origin "$BRANCH"

echo "✅ Done... All changes pushed successfully."
