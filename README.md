# AgensGraph Multiplatform Images

This repository builds and publishes multiplatform Docker images for AgensGraph.

## Purpose

The upstream AgensGraph images at [skaiworldwide/agensgraph](https://hub.docker.com/r/skaiworldwide/agensgraph) only provide AMD64 architecture support. This repository extends support to multiple platforms including ARM64, enabling AgensGraph to run on a wider range of hardware platforms such as Apple Silicon and ARM-based servers.

## Supported Platforms

- linux/amd64
- linux/arm64

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

To build multiplatform images locally:

```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t agensgraph:latest .
```

## Automated Builds

The GitHub Actions workflow automatically builds and pushes images:
- On push to `main` branch
- On version tags (e.g., `v2.16.0`)
- On pull requests (build only, no push)
- Manual trigger via workflow dispatch
