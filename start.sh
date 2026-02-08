# start.sh
#!/bin/bash
echo "Starting development environment..."

docker compose up -d

echo "Environment started!"
echo "Access: http://localhost"
echo "Logs: docker compose logs -f"