# cleanup.sh
#!/bin/bash
echo "Cleaning up environment..."

docker compose down -v
docker system prune -f

echo "Cleanup complete!"