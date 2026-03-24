# AgensGraph Multiplatform Docker Images

## Project Overview

This repository builds and publishes multiplatform Docker images for AgensGraph, a graph database extension for PostgreSQL. The upstream project at https://hub.docker.com/r/skaiworldwide/agensgraph only provides AMD64 images, so this repository extends support to ARM64 and other platforms.

## Repository Structure

```
.
├── Dockerfile                          # Multiplatform Dockerfile for AgensGraph
├── .github/workflows/
│   └── build-multiplatform.yml        # GitHub Actions workflow for CI/CD
└── README.md                          # User documentation
```

## Key Technologies

- **Base Image**: postgres:16-bookworm
- **AgensGraph Version**: v2.16.0 (from https://github.com/skaiworldwide-oss/agensgraph)
- **Build System**: Docker Buildx with QEMU for cross-platform compilation
- **CI/CD**: GitHub Actions
- **Container Registries**: GitHub Container Registry (GHCR) and Docker Hub

## Build Process

The Dockerfile:
1. Starts from PostgreSQL 16 on Debian Bookworm
2. Installs build dependencies (build-essential, libreadline-dev, zlib1g-dev, etc.)
3. Clones AgensGraph v2.16.0 from GitHub
4. Compiles AgensGraph from source using `./configure && make && make install`

## Supported Platforms

- linux/amd64 (x86_64)
- linux/arm64 (ARM 64-bit, including Apple Silicon)

## GitHub Actions Workflow

The CI/CD pipeline (`build-multiplatform.yml`):
- Builds images for each platform in parallel using matrix strategy
- Uses QEMU for cross-platform emulation
- Employs GitHub Actions cache for faster builds
- Creates multi-arch manifest lists
- Publishes to GHCR automatically and Docker Hub optionally
- Triggers on:
  - Push to main branch → `latest` tag
  - Version tags (v*) → semantic version tags
  - Pull requests → build only, no push
  - Manual workflow dispatch

## Container Registry Configuration

### GitHub Container Registry (GHCR)
- Automatically configured via `GITHUB_TOKEN`
- Images published to: `ghcr.io/<owner>/<repo>`

### Docker Hub (Optional)
Requires repository secrets:
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

## Development Guidelines

### Making Changes to the Dockerfile
- Always test builds locally first using `docker buildx build --platform linux/amd64,linux/arm64`
- Keep build dependencies minimal to reduce image size
- Pin AgensGraph version in git clone command

### Updating AgensGraph Version
To release a new AgensGraph version:
1. Create and push a git tag matching the AgensGraph version (e.g., `v2.17.0`)
   ```bash
   git tag -a v2.17.0 -m "Release AgensGraph v2.17.0"
   git push origin v2.17.0
   ```
2. The workflow will automatically build that specific AgensGraph version
3. The Dockerfile accepts `AGENSGRAPH_VERSION` as a build argument (defaults to v2.16.0)
4. Test locally with: `docker build --build-arg AGENSGRAPH_VERSION=v2.17.0 -t agensgraph:test .`

### GitHub Actions Workflow Modifications
- The workflow uses digest-based approach for true multiplatform images
- Each platform builds separately and uploads digests
- The merge job combines digests into a single manifest list
- Maintain this pattern for optimal build parallelization

## Common Tasks

### Building Locally
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t agensgraph:test .
```

### Testing the Image
```bash
docker run -d --name agensgraph-test \
  -e POSTGRES_PASSWORD=testpass \
  -p 5432:5432 \
  agensgraph:test
```

### Triggering Manual Build
- Go to Actions → Build and Push Multiplatform Images → Run workflow

## Important Notes

- Build times: ARM64 builds take significantly longer due to QEMU emulation
- The compilation step (`make -j$(nproc)`) is resource-intensive
- GitHub Actions runners have 2-core CPUs, so builds may take 15-30 minutes per platform
- GHCR images are public by default if the repository is public
