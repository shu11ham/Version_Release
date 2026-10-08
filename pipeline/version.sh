#!/bin/bash

set -e

echo "========================================"
echo "      TaskFlow Release Validation"
echo "========================================"

PROJECT_DIR="/home/shubh/taskflow"

cd "$PROJECT_DIR"

echo ""
echo "1. Validating project structure..."

required_files=(
    "frontend/package.json"
    "frontend/Dockerfile"
    #"frontend/nginx.conf"
    "backend/requirements.txt"
    "backend/Dockerfile"
    "backend/app/main.py"
    "backend/app/database.py"
    "backend/app/models.py"
    "backend/app/schemas.py"
    "backend/app/crud.py"
    "docker-compose.yml"
)

for file in "${required_files[@]}"; do

    if [ ! -f "$file" ]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi

done

echo "Project structure OK"


echo ""
echo "2. Validating React application..."

if [ ! -f "frontend/package.json" ]; then
    echo "ERROR: React package.json not found"
    exit 1
fi

if ! grep -q '"build"' frontend/package.json; then
    echo "ERROR: React build script not found"
    exit 1
fi

echo "React application OK"


echo ""
echo "3. Validating Python application..."

if [ ! -f "backend/app/main.py" ]; then
    echo "ERROR: FastAPI main.py not found"
    exit 1
fi

if ! grep -q "FastAPI" backend/app/main.py; then
    echo "ERROR: FastAPI application not detected"
    exit 1
fi

echo "Python/FastAPI application OK"


echo ""
echo "4. Validating Docker configuration..."

if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker daemon is not running"
    exit 1
fi

echo "Docker OK"


echo ""
echo "5. Validating Docker Compose..."

if ! docker compose config >/dev/null; then
    echo "ERROR: docker-compose.yml is invalid"
    exit 1
fi

echo "Docker Compose configuration OK"


echo ""
echo "6. Building application..."

docker compose build

echo "Docker build successful"


echo ""
echo "7. Starting application..."

docker compose up -d

echo "Application started"


echo ""
echo "8. Waiting for services..."

sleep 10


echo ""
echo "9. Checking containers..."

if ! docker compose ps | grep -q "Up"; then
    echo "ERROR: Containers are not running"
    docker compose ps
    exit 1
fi

docker compose ps


echo ""
echo "10. Checking backend health..."

if ! curl -f http://localhost:8000/health >/dev/null 2>&1; then
    echo "ERROR: Backend health check failed"
    docker compose logs backend
    exit 1
fi

echo "Backend health OK"


echo ""
echo "11. Checking frontend..."

if ! curl -f http://localhost:3000 >/dev/null 2>&1; then
    echo "ERROR: Frontend is not responding"
    docker compose logs frontend
    exit 1
fi

echo "Frontend health OK"


echo ""
echo "12. Checking API..."

if ! curl -f http://localhost:3000/api/tasks >/dev/null 2>&1; then
    echo "ERROR: API through Nginx failed"
    docker compose logs frontend
    exit 1
fi

echo "API OK"


echo ""
echo "13. Checking database..."

if ! docker exec taskflow-database \
    pg_isready -U taskflow -d taskflow >/dev/null 2>&1; then

    echo "ERROR: PostgreSQL is not ready"
    docker compose logs database
    exit 1

fi

echo "Database OK"


echo ""
echo "========================================"
echo "       RELEASE VALIDATION PASSED"
echo "========================================"

echo ""
echo "Application:"
echo "Frontend : http://localhost:3000"
echo "Backend  : http://localhost:8000"
echo "Swagger  : http://localhost:8000/docs"
echo ""
