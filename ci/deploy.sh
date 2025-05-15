#!/bin/bash
set -euo pipefail
export BUILD_ID=dontKillMe

# 1. Ensure we're in the repo root
cd "$(dirname "$0")/.."    # assumes deploy.sh is inside /ci
echo "→ Workspace: $(pwd)"

# 2. Build the JAR
echo "→ Building the project…"
mvn clean package -DskipTests

# 3. Call Ansible to deploy
echo "→ Deploying via Ansible…"
ansible-playbook ci/deploy.yml
