# Docker Template

A streamlined Docker template for Python projects with FastAPI integration, designed for both standard and GPU-accelerated development environments.

## Features

- Multi-stage Docker build for optimized image size
- Poetry-based dependency management
- FastAPI server with hot-reload for development
- NVIDIA GPU support for machine learning workloads
- Persistent volumes for history, VS Code server, and HuggingFace cache
- Makefile for simplified Docker operations

## Prerequisites

- Docker and Docker Compose
- Make (for using the Makefile commands)
- For GPU support: NVIDIA Container Toolkit

## Getting Started

### Basic Setup

1. Clone this repository
2. Update the `pyproject.toml` with your project details and dependencies
3. Build the Docker image:

```bash
make build
```

4. Start the container:

```bash
make up
```

The FastAPI server will be available at http://localhost:8000

### Adding or Updating Dependencies

1. Modify the `pyproject.toml` file with your new dependencies
2. Rebuild the image with the updated dependencies:

```bash
make build-update
```

This command will:
- Delete the existing `poetry.lock` file
- Rebuild the Docker image
- Extract the new `poetry.lock` file from the container

### GPU Support

For machine learning workloads requiring GPU acceleration:

1. Build the GPU-enabled image:

```bash
make build-gpu
```

2. Start the container with GPU support:

```bash
make up-gpu
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make build` | Build the Docker image |
| `make build-update` | Rebuild image and update lock file |
| `make build-gpu` | Build with NVIDIA GPU support |
| `make up` | Start the container |
| `make up-gpu` | Start with NVIDIA GPU support |
| `make command` | Execute bash in running container |
| `make command-raw` | Run a new container with bash |
| `make command-raw-gpu` | Run a new GPU container with bash |
| `make extract-lock` | Extract poetry.lock from container |
| `make clean-requirements` | Remove poetry.lock file |

## Project Structure

- `Dockerfile`: Multi-stage build configuration
- `docker-compose.yaml`: Main Docker Compose configuration
- `docker-compose-nvidia.yaml`: NVIDIA GPU extension
- `pyproject.toml`: Poetry dependency management
- `server.py`: FastAPI application entry point
- `Makefile`: Simplified Docker operations

## Customization

### Updating Dependencies

1. Edit `pyproject.toml` to add/modify dependencies
2. Run `make build-update` to rebuild with new dependencies
3. The updated `poetry.lock` will be extracted automatically

### Modifying the FastAPI Server

The `server.py` file contains a minimal FastAPI setup. Extend it by:
- Adding new routes
- Implementing middleware
- Connecting to databases
- Organizing larger projects into modules

## Notes

- External volumes (`root_hist`, `vscode-server`, `huggingface-cache`) must exist before running the containers
- Debug mode can be enabled by setting the `DEBUG` environment variable
- VS Code debugging is pre-configured but commented out in the docker-compose file