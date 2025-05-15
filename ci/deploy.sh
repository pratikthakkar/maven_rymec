#!/bin/bash
set -e

echo "Killing any running instance..."
pkill -f "mvn spring-boot:run" || true
sleep 2

echo "Starting Spring Boot in background..."
nohup mvn spring-boot:run -Dspring-boot.run.arguments="--server.port=8888" > boot.log 2>&1 &

# Wait for the app to be ready
echo "Waiting for Spring Boot to respond..."

max_attempts=30
attempt=0
until curl -s -o /dev/null -w "%{http_code}" http://localhost:8888 | grep -q "200"; do
  if (( attempt >= max_attempts )); then
    echo "❌ App failed to start within $((max_attempts * 2)) seconds"
    tail -n 30 boot.log
    exit 1
  fi
  attempt=$((attempt+1))
  echo "Waiting... ($attempt)"
  sleep 2
done

echo "✅ Spring Boot is up!"
