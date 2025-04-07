FROM python:3.12-slim AS build
# FROM nvidia/cuda:12.1.0-base-ubi8 as build
LABEL maintainer="ryan@balch.io"

# Install system packages required by System/Python.
RUN apt update -y \
  && apt install --no-install-recommends -y \
    build-essential \
    git \
    vim \
    make \
    python3-dev \
    python3-pip \
    python3-venv

# Use /code folder as a directory where the source code is stored.
WORKDIR /code

# Set up a Python virtual environment and activate it.
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set environment variables.
ENV PYTHONUNBUFFERED 1
ENV PYTHONPATH="$PYTHONPATH:/code"

# Setup history
RUN mkdir /root/history
ENV HISTFILE=/root/history/.bash_history
ENV PROMPT_COMMAND="history -a"

# build huggingface cache
RUN mkdir -p /huggingface_cache
ENV HF_DATASETS_CACHE="/huggingface_cache"

# Setup pip-tools
RUN pip install pip-tools

# Copy requirements files
COPY requirements.txt .
# Copy lock file if it exists
COPY requirements.lock* .

# ARG to control whether to update dependencies
ARG UPDATE_DEPS=false

# Generate lock file only if UPDATE_DEPS=true or if requirements.lock doesn't exist
RUN if [ "$UPDATE_DEPS" = "true" ] || [ ! -f requirements.lock ]; then \
        echo "Generating new requirements.lock..." && \
        pip-compile --output-file=requirements.lock requirements.txt; \
    else \
        echo "Using existing requirements.lock"; \
    fi

# Install dependencies
RUN pip install -r requirements.lock

FROM build AS runtime
# Copy app code
COPY . .

# Run app
# where app lives ex: ["streamlit", "run"]
ENTRYPOINT ["uvicorn", "server:app"] 
# actual command to run - this allows for easy override of file or adding switches
# ex: ["app.py"]
CMD ["--host", "0.0.0.0", "--port", "8080"]
