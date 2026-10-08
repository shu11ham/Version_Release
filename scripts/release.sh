#!/bin/bash

set -e

# ==========================================
# TaskFlow Release Script
# ==========================================

PROJECT_DIR="/home/shubh/taskflow"

cd "$PROJECT_DIR"

echo "=========================================="
echo "        TASKFLOW RELEASE"
echo "=========================================="

# ------------------------------------------
# 1. Determine release version
# ------------------------------------------

if [ -z "$BUILD_NUMBER" ]; then

    echo "BUILD_NUMBER not found."
    echo "Using local release numbering."

    LAST_RELEASE=$(find releases -mindepth 1 -maxdepth 1 -type d \
        -printf "%f\n" 2>/dev/null | sort -n | tail -1)

    if [ -z "$LAST_RELEASE" ]; then
        RELEASE_VERSION=1
    else
        RELEASE_VERSION=$((LAST_RELEASE + 1))
    fi

else

    RELEASE_VERSION="$BUILD_NUMBER"

fi


echo ""
echo "Release version: $RELEASE_VERSION"


# ------------------------------------------
# 2. Get Git commit
# ------------------------------------------

GIT_COMMIT=$(git rev-parse --short HEAD)

echo "Git commit: $GIT_COMMIT"


# ------------------------------------------
# 3. Create release directory
# ------------------------------------------

RELEASE_DIR="$PROJECT_DIR/releases/$RELEASE_VERSION"

if [ -d "$RELEASE_DIR" ]; then

    echo "ERROR: Release $RELEASE_VERSION already exists."

    exit 1

fi

mkdir -p "$RELEASE_DIR"


# ------------------------------------------
# 4. Docker image names
# ------------------------------------------

FRONTEND_IMAGE="taskflow-frontend:$GIT_COMMIT"
BACKEND_IMAGE="taskflow-backend:$GIT_COMMIT"


# ------------------------------------------
# 5. Build Docker images
# ------------------------------------------

echo ""
echo "Building frontend image..."

docker build \
    -t "$FRONTEND_IMAGE" \
    ./frontend


echo ""
echo "Building backend image..."

docker build \
    -t "$BACKEND_IMAGE" \
    ./backend


# ------------------------------------------
# 6. Save release information
# ------------------------------------------

cat > "$RELEASE_DIR/release-info.txt" <<EOF
TaskFlow Release

Release Version:
$RELEASE_VERSION

Git Commit:
$GIT_COMMIT

Frontend Image:
$FRONTEND_IMAGE

Backend Image:
$BACKEND_IMAGE

Created At:
$(date '+%Y-%m-%d %H:%M:%S')

Status:
CREATED
EOF


# ------------------------------------------
# 7. Create current release pointer
# ------------------------------------------

ln -sfn "$RELEASE_DIR" "$PROJECT_DIR/current"


# ------------------------------------------
# 8. Show release information
# ------------------------------------------

echo ""
echo "=========================================="
echo "       RELEASE CREATED SUCCESSFULLY"
echo "=========================================="

echo ""
cat "$RELEASE_DIR/release-info.txt"

echo ""
echo "Current release:"
readlink -f "$PROJECT_DIR/current"

echo ""
echo "Docker images:"
docker images | grep taskflow || true

echo ""
echo "=========================================="
