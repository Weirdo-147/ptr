#!/bin/bash

# Set repository details
REPO="/workspaces/ptr"
BASE_BRANCH="main"

while true; do
    BRANCH="pull-shark-$(date +%s)"  # Unique branch name

    # Clone the repo if not already cloned
    if [ ! -d "${REPO##*/}" ]; then
        git clone "https://github.com/$REPO.git"
    fi
    cd "${REPO##*/}"

    # Make sure we're on the latest main branch
    git checkout "$BASE_BRANCH"
    git pull origin "$BASE_BRANCH"

    # Create a new branch
    git checkout -b "$BRANCH"

    # Make a small change (modify README.md)
    echo "Pull Shark PR test $(date)" >> README.md

    # Commit & push the change
    git add README.md
    git commit -m "Automated PR for Pull Shark badge"
    git push origin "$BRANCH"

    # Create a Pull Request
    PR_URL=$(gh pr create --base "$BASE_BRANCH" --head "$BRANCH" --title "Auto PR for Pull Shark Badge" --body "This PR is for the Pull Shark badge." --json url -q '.url')

    echo "PR Created: $PR_URL"

    # Wait 5 seconds to allow PR processing
    sleep 1

    # Merge the PR
    gh pr merge --merge "$BRANCH"

    # Delete the branch
    git branch -d "$BRANCH"
    gh repo sync

    # Wait 1 second before the next PR
    sleep 1
done
