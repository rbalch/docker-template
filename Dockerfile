FROM python:3.12-slim as builder
# FROM nvidia/cuda:12.1.0-base-ubi8 as build
LABEL maintainer="ryan@balch.io"

# Set environment variables.
# 1. Force Python stdout and stderr streams to be unbuffered.
ENV PYTHONUNBUFFERED 1

RUN mkdir /root/history
ENV HISTFILE=/root/history/.bash_history
ENV PROMPT_COMMAND="history -a"

# Install system packages required by System/Python.
RUN apt update -y \
  && apt install --no-install-recommends -y \
    build-essential \
    git \
    postgresql-client \
    vim \
    python3-dev \
    python3-pip \
    python3-venv \
    make

# Use /code folder as a directory where the source code is stored.
WORKDIR /code

# Set up a Python virtual environment and activate it.
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set the PYTHONPATH environment variable.
ENV PYTHONPATH="$PYTHONPATH:/code"

# build huggingface cache
RUN mkdir -p /huggingface_cache
ENV HF_DATASETS_CACHE="/huggingface_cache"

# Setup pip-tools
RUN pip install pip-tools

# Copy reqs files
COPY requirements.* .

# Check for the existence of requirements.lock and proceed accordingly
RUN if [ -f requirements.lock ]; then \
        pip-sync requirements.lock; \
    else \
        pip-compile --output-file=requirements.lock requirements.txt && \
        pip-sync requirements.lock; \
    fi

FROM builder as deploy
COPY . .

# Run app
# where app lives ex: ["streamlit", "run"]
ENTRYPOINT ["uvicorn", "server:app"] 
# actual command to run - this allows for easy override of file or adding switches
# ex: ["app.py"]
CMD ["--host", "0.0.0.0", "--port", "8080"]
