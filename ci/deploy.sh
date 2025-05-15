#!/bin/bash
set -euo pipefail

# 1. Go to your workspace
cd "$(dirname "$0")/.."    # adjust if deploy.sh is elsewhere
echo "→ Workspace: $(pwd)"

# 2. Build the JAR
echo "→ Building the project…"
mvn clean package -DskipTests

# 3. Reload systemd (in case you ever update the unit file)
echo "→ Reloading systemd…"
sudo systemctl daemon-reload

# 4. Restart the service
echo "→ Restarting Spring Boot service…"
sudo systemctl restart student-passfail

# 5. Health-check loop (same as before)
echo "→ Waiting for HTTP 200 on http://localhost:8888 …"
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:8888 | grep -q "^200$"; then
    echo "✅ Application is responding!"
    exit 0
  fi
  echo "   …waiting ($i/30)…"
  sleep 2
done

echo "❌ App never responded—dumping last 50 lines of journal:"
sudo journalctl -u student-passfail -n 50 --no-pager
exit 1
