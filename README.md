# AgensGraph Multiplatform Images

This repository builds and publishes multiplatform Docker images for AgensGraph.

## Purpose

The upstream AgensGraph images at [skaiworldwide/agensgraph](https://hub.docker.com/r/skaiworldwide/agensgraph) only provide AMD64 architecture support. This repository extends support to multiple platforms including ARM64, enabling AgensGraph to run on a wider range of hardware platforms such as Apple Silicon and ARM-based servers.

## Supported Platforms

- linux/amd64
- linux/arm64

## Available Versions

This repository tracks the official upstream releases from [skaiworldwide-oss/agensgraph](https://github.com/skaiworldwide-oss/agensgraph).

**Current latest**: v2.16.0

For all available versions, see: https://github.com/skaiworldwide-oss/agensgraph/releases

## Setup

### GitHub Actions Secrets

To enable automated builds and publishing, configure the following secrets in your GitHub repository:

**Required:**
- `GITHUB_TOKEN` - Automatically provided by GitHub Actions

**Optional (for Docker Hub publishing):**
- `DOCKERHUB_USERNAME` - Your Docker Hub username
- `DOCKERHUB_TOKEN` - Docker Hub access token

### Container Registries

Images are automatically published to:
- **GitHub Container Registry (GHCR)**: `ghcr.io/<your-username>/agensgraph`
- **Docker Hub** (if credentials configured): `<dockerhub-username>/agensgraph`

## Usage

Pull the image for your platform:

```bash
# From GitHub Container Registry
docker pull ghcr.io/<your-username>/agensgraph:latest

# From Docker Hub (if published)
docker pull <dockerhub-username>/agensgraph:latest
```

Run AgensGraph:

```bash
docker run -d \
  --name agensgraph \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  ghcr.io/<your-username>/agensgraph:latest
```

## Building Locally

### Using Task (Recommended)

First, install [Task](https://taskfile.dev/):

```bash
# macOS
brew install go-task

# Linux
sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b /usr/local/bin

# Or with Go
go install github.com/go-task/task/v3/cmd/task@latest
```

Then use the provided Taskfile:

```bash
# Quick build for current platform
task build

# Build and test
task test

# Run locally
task run

# Build specific version
task build:version -- v2.15.0

# See all available tasks
task --list
task help
```

### Using Docker directly

Build for current platform:
```bash
docker build --build-arg AGENSGRAPH_VERSION=v2.16.0 -t agensgraph:latest .
```

Build multiplatform:
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t agensgraph:latest .
```

**Note**: Always use official upstream versions from https://github.com/skaiworldwide-oss/agensgraph/releases

## Automated Builds

The GitHub Actions workflow automatically builds and pushes images:
- On version tags (e.g., `v2.16.0`) - builds matching AgensGraph version
- On GitHub releases
- Manual trigger via workflow dispatch

The workflow automatically detects the version from the Git tag and builds that specific AgensGraph version.
