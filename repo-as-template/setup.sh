#!/bin/bash
# This script performs the following tasks:
# - Copy template scripts and config files to repository root
# - Run the 'run-after-clone.sh' script
# - Commit the changes

templateDir=$(dirname "$0")
resourcesDir=$templateDir/resources
rootDir=$templateDir/..

# Check Git status
if [[ ! -z $(git status -s) ]]; then
  echo "Error: Git working tree must be clean before running this script"
  exit 1
fi

# Check parameters
if [ -z ${1+x} ]; then
  echo "Usage: $0 <remote repository>"
  exit 1
fi

remoteRepo=$1

function rmTemplateReadme() {
  git rm -f "$rootDir/README.md" && git commit -m "Remove template README.md"
}

function pullRemote() {
  git pull --allow-unrelated-histories "$remoteRepo" --no-commit && git add . && git commit -m "Pull $1"
}

function moveOrgReadme() {
  if [[ -f "$rootDir/README.md" ]] && [[ ! -f "$rootDir/README-org.md" ]] ; then
    mv -v "$rootDir/README.md" "$rootDir/README-org.md"
  fi
}

function copyResources() {
  cp -v "$resourcesDir/*" "$rootDir";
}

function createPullScript() {
  cat <<EOF > "$templateDir/pull.sh"
#!/bin/bash
# This script pulls the latest changes from the main sample repository
git pull "$remoteRepo" --allow-unrelated-histories --no-edit
EOF
}

function runAfterClone() {
  "$rootDir/run-after-clone.sh"
}

function commit() {
  git add .
  git commit -m "Setup as derived repository"
}

function createReadme() {
  cat <<EOF > "$rootDir/README.md"
# Derived from $remoteRepo

*Please run the `./run-after-clone.sh` script after cloning this repository*

*Describe derived repository contents*

This project is derived from $remoteRepo.
EOF
}

rmTemplateReadme && pullRemote && moveOrgReadme && copyResources && createPullScript && runAfterClone && commit && createReadme