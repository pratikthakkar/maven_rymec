#!/bin/bash
set -euo pipefail

# 1. Ensure we're in the workspace (contains pom.xml / target/)
cd "$(dirname "$0")/.."    # if deploy.sh lives in ci/, adjust accordingly
echo "→ Workspace: $(pwd)"

# 2. Build the JAR
echo "→ Building the project…"
mvn clean package -DskipTests

# 3. Kill anything on port 8888
echo "→ Killing any process using port 8888…"
fuser -k 8888/tcp 2>/dev/null || true

# 4. Rotate boot.log
echo "→ Clearing old logs…"
: > boot.log

# 5. Start the JAR in background
echo "→ Starting Spring Boot (java -jar)…"
nohup java -jar target/*.jar --server.port=8888 > boot.log 2>&1 &

# 6. Wait for health
echo "→ Waiting for /actuator/health (max ~60s)…"
for i in {1..30}; do
  if curl -s http://localhost:8888/actuator/health \
       | grep -q '"status":"UP"' ; then
    echo "✅ Application is healthy!"
    exit 0
  fi
  echo "   …still waiting ($i/30)…"
  sleep 2
done

echo "❌ Application didn’t come up in time. Dumping boot.log:"
tail -n 50 boot.log
exit 1
