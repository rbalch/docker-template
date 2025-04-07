# docker-template
standard template to clone a new project

## Use

1. Clone repo
2. Change docker-compose.yaml service name
3. If using nvidia/gpu, change docker-extras/nvidia.yaml
4. Look at Makefile for built-in commands

## Dependency Management

This project uses pip-tools for dependency management with a two-mode approach:

### Normal Development
- Add your dependencies to `requirements.txt`
- Run `make build` to build using the existing lock file
- First-time builds will automatically generate a lock file

### Updating Dependencies
- To update all dependencies to their latest versions:
  ```bash
  make requirements-update  # Updates requirements.lock
  make build               # Rebuilds with new dependencies
  ```

- To force a build with fresh dependencies:
  ```bash
  make build-update
  ```

- To remove the lock file and start fresh:
  ```bash
  make clean-requirements
  make build  # Will generate a new lock file
  ```

## Available Commands

- `make build` - Build container (uses locked dependencies)
- `make build-update` - Build container with fresh dependencies
- `make up` - Start container
- `make build-gpu` - Build with NVIDIA support
- `make up-gpu` - Start container with NVIDIA support
- `make command` - Open shell in running container
- `make command-raw` - Run container with shell
- `make command-raw-gpu` - Run container with shell (NVIDIA)
