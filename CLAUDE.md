# AgensGraph Multiplatform Docker Images

## Project Overview

This repository builds and publishes multiplatform Docker images for AgensGraph, a graph database extension for PostgreSQL. The upstream project at https://hub.docker.com/r/skaiworldwide/agensgraph only provides AMD64 images, so this repository extends support to ARM64 and other platforms.

## Upstream Information

- **Source Repository**: https://github.com/skaiworldwide-oss/agensgraph
- **Official Releases**: https://github.com/skaiworldwide-oss/agensgraph/releases
- **Latest Version**: v2.16.0 (as of 2025-09-12)

**IMPORTANT**: Always use official upstream release versions. Check the releases page before creating new tags.

## Repository Structure

```
.
├── Dockerfile                          # Multiplatform Dockerfile with version argument
├── Taskfile.yaml                      # Task runner for local development
├── .github/workflows/
│   └── build-multiplatform.yml        # GitHub Actions workflow for CI/CD
├── CLAUDE.md                          # Context file for Claude (this file)
└── README.md                          # User documentation
```

## Current Status

### Released Versions
- **v2.16.0**: Initial release with multiplatform support (linux/amd64, linux/arm64)

### Repository
- **Organization**: https://github.com/pinaka-io
- **Repository**: https://github.com/pinaka-io/agensgraph
- **Container Images**: https://github.com/pinaka-io/agensgraph/pkgs/container/agensgraph

### Workflow History
- Initial workflow had syntax errors (invalid Docker Hub references, artifact naming issues)
- Fixed in commit c9abd97 by removing Docker Hub and fixing artifact names
- Added package permissions in commit 16ccc07
- Changed triggers to tags/releases only in commit cddb307
- Made version dynamic based on Git tags in commit 5075f02

## Key Technologies

- **Base Image**: postgres:16-bookworm
- **AgensGraph Version**: Dynamic, based on Git tag (defaults to v2.16.0)
- **Build System**: Docker Buildx with QEMU for cross-platform compilation
- **CI/CD**: GitHub Actions
- **Container Registry**: GitHub Container Registry (GHCR)

## Build Process

The Dockerfile:
1. Accepts `AGENSGRAPH_VERSION` build argument (defaults to v2.16.0)
2. Starts from PostgreSQL 16 on Debian Bookworm
3. Installs build dependencies (build-essential, libreadline-dev, zlib1g-dev, flex, bison, git, libicu-dev, pkg-config)
4. Clones AgensGraph from GitHub at the specified version tag
5. Compiles AgensGraph from source using `./configure && make -j$(nproc) && make install`

The version is dynamically set during the build based on the Git tag that triggered the workflow.

## Supported Platforms

- linux/amd64 (x86_64)
- linux/arm64 (ARM 64-bit, including Apple Silicon)

## GitHub Actions Workflow

The CI/CD pipeline (`build-multiplatform.yml`):

### Architecture
- **Matrix Strategy**: Builds linux/amd64 and linux/arm64 in parallel
- **Digest-Based Approach**: Each platform builds separately and uploads digests
- **Manifest Merging**: Final job combines digests into a single multi-arch manifest
- **QEMU Emulation**: Enables cross-platform compilation on GitHub runners
- **GitHub Actions Cache**: Speeds up subsequent builds

### Triggers
- **Version tags (v\*)**: Automatically builds matching AgensGraph version
- **GitHub Releases**: Builds when a release is published
- **Manual dispatch**: Can be triggered manually via Actions UI

**Note**: Does NOT trigger on pushes to main to conserve CI resources.

### Permissions
```yaml
permissions:
  contents: read
  packages: write
```
Required for pushing images to GitHub Container Registry (GHCR).

### Workflow Steps
1. **Extract version from tag**: Determines AgensGraph version from Git tag
2. **Build jobs** (parallel for each platform):
   - Checkout code
   - Set up QEMU for emulation
   - Configure Docker Buildx
   - Login to GHCR
   - Build image with version-specific build argument
   - Push by digest (not by tag yet)
   - Upload digest as artifact
3. **Merge job**:
   - Download all digests
   - Create multi-arch manifest combining all platforms
   - Push final manifest with proper tags
   - Inspect and verify the image

## Container Registry Configuration

### GitHub Container Registry (GHCR)
- **Authentication**: Automatically configured via `GITHUB_TOKEN`
- **Image Location**: `ghcr.io/pinaka-io/agensgraph`
- **Visibility**: Public (matches repository visibility)
- **Tags Generated**:
  - `vX.Y.Z` - Semantic version matching Git tag (e.g., `v2.16.0`)
  - `vX.Y` - Major.minor version (e.g., `v2.16`)
  - `vX` - Major version (e.g., `v2`)
  - `latest` - Latest build from default branch (currently disabled since we don't build on main)

### Docker Hub
Docker Hub publishing has been removed from the workflow to simplify the setup. GHCR is sufficient for public distribution.

## Development Guidelines

### Making Changes to the Dockerfile
- Always test builds locally first using `docker buildx build --platform linux/amd64,linux/arm64`
- Keep build dependencies minimal to reduce image size
- Pin AgensGraph version in git clone command

### Updating AgensGraph Version

**CRITICAL**: Always check the upstream releases first: https://github.com/skaiworldwide-oss/agensgraph/releases

To release a new AgensGraph version:
1. Verify the version exists in upstream releases
2. Create and push a git tag matching the exact AgensGraph version
   ```bash
   # Example: Building v2.15.0
   git tag -a v2.15.0 -m "Release AgensGraph v2.15.0"
   git push origin v2.15.0
   ```
3. The workflow will automatically build that specific AgensGraph version
4. The Dockerfile accepts `AGENSGRAPH_VERSION` as a build argument (defaults to v2.16.0)
5. Test locally with: `docker build --build-arg AGENSGRAPH_VERSION=v2.15.0 -t agensgraph:test .`

Available upstream versions include: v2.16.0 (latest), v2.15.0, v2.14.1, v2.13.1, v2.13.0, v2.12.1, v2.12.0, v2.5.0, etc.

### GitHub Actions Workflow Modifications
- The workflow uses digest-based approach for true multiplatform images
- Each platform builds separately and uploads digests
- The merge job combines digests into a single manifest list
- Maintain this pattern for optimal build parallelization

## Local Development with Taskfile

This repository includes a Taskfile.yaml for streamlined local development. [Task](https://taskfile.dev/) is a task runner similar to Make but uses YAML.

### Quick Reference

```bash
# Build and test
task build              # Build for current platform
task test               # Build and run tests
task test:full          # Full integration tests

# Run locally
task run                # Start container on port 5432
task psql               # Connect with psql
task logs               # View logs
task stop               # Stop and remove container

# Multiplatform
task build:multiplatform   # Build for amd64 and arm64

# Version management
task build:version -- v2.15.0  # Build specific version
task tag:create -- v2.16.0     # Create and push tag
task check:upstream            # Check upstream releases

# Cleanup
task clean              # Remove built images
task clean:all          # Remove everything

# Help
task --list            # List all tasks
task help              # Detailed help
```

## Common Tasks

### Releasing a New Version

1. **Check upstream releases first**:
   ```bash
   gh release list --repo skaiworldwide-oss/agensgraph --limit 10
   ```

2. **Create and push a tag matching the upstream version**:
   ```bash
   # Example for v2.15.0
   git tag -a v2.15.0 -m "Release AgensGraph v2.15.0"
   git push origin v2.15.0
   ```

3. **Monitor the build**:
   ```bash
   gh run watch --repo pinaka-io/agensgraph
   ```

4. **Verify the image**:
   ```bash
   docker pull ghcr.io/pinaka-io/agensgraph:v2.15.0
   docker run --rm ghcr.io/pinaka-io/agensgraph:v2.15.0 agens --version
   ```

### Building Locally

**Using Taskfile** (recommended):
```bash
# Quick build for testing
task build

# Build specific version
task build:version -- v2.15.0

# Multiplatform build
task build:multiplatform

# Build and test
task test
```

**Using Docker directly**:

Single platform (faster for testing):
```bash
docker build --build-arg AGENSGRAPH_VERSION=v2.16.0 -t agensgraph:test .
```

Multiplatform (requires buildx):
```bash
docker buildx create --use --name multiplatform-builder
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg AGENSGRAPH_VERSION=v2.16.0 \
  -t agensgraph:test \
  --load .
```

### Testing the Image

**Using Taskfile**:
```bash
# Basic tests
task test

# Full integration tests
task test:full

# Verify image works
task verify

# Manual testing
task run                # Start container
task psql               # Connect with psql
task logs               # View logs
task stop               # Clean up
```

**Using Docker directly**:
```bash
# Start AgensGraph container
docker run -d --name agensgraph-test \
  -e POSTGRES_PASSWORD=testpass \
  -p 5432:5432 \
  ghcr.io/pinaka-io/agensgraph:v2.16.0

# Check logs
docker logs agensgraph-test

# Connect with psql
docker exec -it agensgraph-test psql -U postgres

# Test graph functionality
docker exec -it agensgraph-test psql -U postgres -c "SELECT version();"

# Clean up
docker stop agensgraph-test && docker rm agensgraph-test
```

### Triggering Manual Build
```bash
# Via GitHub CLI
gh workflow run build-multiplatform.yml --repo pinaka-io/agensgraph

# Or via web UI:
# https://github.com/pinaka-io/agensgraph/actions/workflows/build-multiplatform.yml
# Click "Run workflow"
```

### Checking Build Status
```bash
# List recent runs
gh run list --repo pinaka-io/agensgraph --limit 5

# Watch a specific run
gh run watch <run-id> --repo pinaka-io/agensgraph

# View logs for failed run
gh run view <run-id> --repo pinaka-io/agensgraph --log-failed
```

### Managing Tags

**Using Taskfile**:
```bash
# Create and push a tag
task tag:create -- v2.16.0

# Delete a tag (local and remote)
task tag:delete -- v2.16.0

# Check upstream releases
task check:upstream

# Check build status
task check:builds
task watch:build
```

**Using Git directly**:
```bash
# List all tags
git tag -l

# Delete a local tag
git tag -d v2.16.0

# Delete a remote tag (this will NOT stop an in-progress build)
git push origin --delete v2.16.0

# Retag (if you need to fix something)
git tag -d v2.16.0
git push origin --delete v2.16.0
git tag -a v2.16.0 -m "Release AgensGraph v2.16.0"
git push origin v2.16.0
```

## Important Notes

### Build Performance
- **ARM64 builds**: Take significantly longer (15-30 minutes) due to QEMU emulation
- **Compilation**: The `make -j$(nproc)` step is CPU-intensive
- **GitHub Runners**: Free tier has 2-core CPUs, which limits parallelization
- **Total build time**: Expect 20-40 minutes for both platforms combined

### Registry & Permissions
- **GHCR visibility**: Images are public by default since the repository is public
- **Package permissions**: The workflow has `packages: write` permission to push to GHCR
- **Tag lifecycle**: Tags are immutable once pushed; use new versions for updates

### Version Management
- **Git tags MUST match upstream**: Always verify version exists at https://github.com/skaiworldwide-oss/agensgraph/releases
- **No automatic updates**: This repository does not auto-detect new upstream versions
- **Manual tagging required**: Create and push tags manually to trigger builds

### Troubleshooting
- **Workflow not triggering**: Ensure you pushed a tag starting with `v` (e.g., `v2.16.0`)
- **Build failures**: Check if the upstream AgensGraph version exists and builds successfully
- **Permission denied**: Verify the repository has the `packages: write` permission set
- **Artifact name errors**: Platform names are converted to job indexes to avoid slash characters in artifact names
