# docker-template
standard template to clone a new project

## Use

1. Clone repo
2. Change docker-compose.yaml service name
3. If using nvidia/gpu, change docker-extras/nvidia.yaml
4. Look at Makefile for built-in commands

## Dependency Management

This project uses uv for dependency management with a two-mode approach:

### Normal Development
- Add your dependencies to `requirements.txt`
- Run `make build` to build using the existing lock file
- All builds automatically extract the requirements.lock file to your local directory

### Updating Dependencies
- To update all dependencies to their latest versions:
  ```bash
  make requirements-update  # Updates dependencies and extracts requirements.lock
  ```

- To force a build with fresh dependencies:
  ```bash
  make build-update  # Same as requirements-update
  ```

- To remove the lock file and start fresh:
  ```bash
  make clean-requirements
  make build  # Will generate a new lock file and extract it
  ```

## About uv

[uv](https://github.com/astral-sh/uv) is a fast Python package installer and resolver written in Rust. It offers:

- Up to 10x faster dependency resolution than pip
- Compatible with existing requirements.txt and lock files
- Parallel downloads and installations
- Better error messages and stricter dependency resolution

This project uses the following uv commands:
- `uv pip compile` - Generate lock file from requirements.txt
- `uv pip sync` - Install packages from lock file

## Available Commands

- `make build` - Build container (uses locked dependencies) and extract lock file
- `make build-update` - Build container with fresh dependencies and extract lock file
- `make build-gpu` - Build with NVIDIA support and extract lock file
- `make up` - Start container
- `make up-gpu` - Start container with NVIDIA support
- `make command` - Open shell in running container
- `make command-raw` - Run container with shell
- `make command-raw-gpu` - Run container with shell (NVIDIA)
- `make extract-lock` - Extract requirements.lock from the container
- `make clean-requirements` - Remove requirements.lock file
