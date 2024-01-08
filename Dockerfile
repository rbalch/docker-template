FROM python:3.11-slim as build
# FROM nvidia/cuda:12.1.0-base-ubi8 as build
LABEL maintainer="ryan@balch.io"

# Set environment variables.
# 1. Force Python stdout and stderr streams to be unbuffered.
ENV PYTHONUNBUFFERED 1

RUN mkdir /root/history
ENV HISTFILE=/root/history/.bash_history
ENV PROMPT_COMMAND="history -a"

# # Install system packages required by System/Python.
# RUN apt update -y \
#   && apt install --no-install-recommends -y \
#     build-essential \
#     ffmpeg \
#     libjpeg-dev \
#     libmagickwand-dev \
#     libpq-dev \
#     libwebp-dev \
#     postgresql-client \
#     zlib1g-dev \
#   && apt-get purge -y --auto-remove \
#   && apt-get clean \
#   && rm -rf /var/lib/apt/lists/*

# Use /code folder as a directory where the source code is stored.
WORKDIR /code
ENV PYTHONPATH="$PYTHONPATH:/code"

# build huggingface cache
RUN mkdir -p /huggingface_cache
ENV HF_DATASETS_CACHE="/huggingface_cache"
# RUN pip install transformers>=4.36.2
# COPY docker-extras/setup.py .
# RUN python setup.py

# Install the project requirements.
COPY requirements.txt .
RUN pip install -r requirements.txt

# Run app
# where app lives ex: ["stremlit", "run"]
# ENTRYPOINT [] 
# actual command to run - this allows for easy override of file or adding switches
# ex: ["app.py"]
# CMD []
