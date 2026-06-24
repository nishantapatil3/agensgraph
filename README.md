# AgensGraph Multiplatform Images

[![Build Status](https://github.com/nishantapatil3/agensgraph/actions/workflows/build-multiplatform.yml/badge.svg)](https://github.com/nishantapatil3/agensgraph/actions/workflows/build-multiplatform.yml)

Multiplatform Docker images for [AgensGraph](https://github.com/skaiworldwide-oss/agensgraph), a graph database extension for PostgreSQL.

## Why This Repository?

The upstream AgensGraph images at [skaiworldwide/agensgraph](https://hub.docker.com/r/skaiworldwide/agensgraph) **only support AMD64**. This repository provides:

- **Multi-architecture support** - linux/amd64, linux/arm64
- **Apple Silicon compatibility** - Native ARM64 builds
- **Automated builds** - CI/CD pipeline with version tracking

## Quick Start

```bash
# Pull and run
docker pull ghcr.io/nishantapatil3/agensgraph:v2.17.0
docker run -d \
  --name agensgraph \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  ghcr.io/nishantapatil3/agensgraph:v2.17.0

# Connect with psql
docker exec -it agensgraph psql -U postgres
```

## Available Versions

This repository tracks official upstream releases from [skaiworldwide-oss/agensgraph](https://github.com/skaiworldwide-oss/agensgraph/releases).

**Current latest**: v2.17.0

All released images: [ghcr.io/nishantapatil3/agensgraph](https://github.com/nishantapatil3/agensgraph/pkgs/container/agensgraph)

## Usage

### Pull the Image

```bash
docker pull ghcr.io/nishantapatil3/agensgraph:v2.17.0
```

### Run AgensGraph

```bash
docker run -d \
  --name agensgraph \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  ghcr.io/nishantapatil3/agensgraph:v2.17.0
```

### Connect to AgensGraph

```bash
# Using psql
docker exec -it agensgraph psql -U postgres

# Check version
docker exec -it agensgraph psql -U postgres -c "SELECT version();"
```

## Building Locally

### Single platform

```bash
docker build -t agensgraph:latest .
```

### Multiplatform

```bash
docker buildx create --use
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t agensgraph:latest \
  .
```

## CI/CD Pipeline

Images are automatically built and published via GitHub Actions:

**Triggers:**
- Version tags (e.g., `v2.17.0`) — builds and tags as that version
- Main branch pushes — tags as `main` and `main-<sha>`
- Manual workflow dispatch

**Build Process:**
1. Parallel builds for linux/amd64 and linux/arm64 using QEMU
2. Compiles AgensGraph from source for each platform
3. Creates multi-arch manifest
4. Publishes to GitHub Container Registry (GHCR)

Check build status: [GitHub Actions](https://github.com/nishantapatil3/agensgraph/actions)

## Repository Structure

```
.
├── Dockerfile                     # Multiplatform build (postgres:17 + AgensGraph v2.17.0)
├── .github/workflows/
│   └── build-multiplatform.yml   # CI/CD pipeline
└── README.md                      # This file
```

## Releasing a New Version

1. Update the version in `Dockerfile` (the `git clone --branch` line)
2. Commit and push to main
3. Create and push a tag:
   ```bash
   git tag -a v2.17.0 -m "Release AgensGraph v2.17.0"
   git push origin v2.17.0
   ```
4. The workflow builds and publishes `ghcr.io/nishantapatil3/agensgraph:v2.17.0`

Always verify the version exists upstream: https://github.com/skaiworldwide-oss/agensgraph/releases

## Links

- **Images**: [ghcr.io/nishantapatil3/agensgraph](https://github.com/nishantapatil3/agensgraph/pkgs/container/agensgraph)
- **Source**: [github.com/nishantapatil3/agensgraph](https://github.com/nishantapatil3/agensgraph)
- **Upstream**: [github.com/skaiworldwide-oss/agensgraph](https://github.com/skaiworldwide-oss/agensgraph)

## License

This repository follows the same license as the upstream AgensGraph project.
