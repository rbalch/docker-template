# === Builder Stage ===
FROM python:3.12-slim AS base
# FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 as base

# Install build tools and required system packages
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    vim \
    python3-dev \
    python3-pip \
    curl \
    docker.io \
    inotify-tools \
    zsh \
    fzf \
    unzip \
    fontconfig \
    ca-certificates 

WORKDIR /code

# Set environment variables for Python behavior and module discovery
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="$PYTHONPATH:/code"

# Setup history for interactive sessions (ensuring it’s mappable with a volume)
RUN mkdir -p /root/history
ENV HISTFILE=/root/history/.zsh_history
# zsh writes instantly with INC_APPEND_HISTORY; PROMPT_COMMAND is bash-only

# --- zsh + Oh My Zsh + Powerlevel10k + plugins ---
# Install Oh My Zsh unattended
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Powerlevel10k theme and plugins (autosuggestions + syntax highlighting)
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.oh-my-zsh/custom/themes/powerlevel10k \
    && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Nerd Font: MesloLGS (helps in GUI/tmux; still install Meslo so apps in-container can render it)
RUN mkdir -p /usr/local/share/fonts \
    && curl -fsSL -o /tmp/Meslo.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip \
    && unzip -q /tmp/Meslo.zip -d /usr/local/share/fonts/meslo \
    && fc-cache -f \
    && rm -f /tmp/Meslo.zip

# zsh config
RUN printf '%s\n' \
    'export ZSH="$HOME/.oh-my-zsh"' \
    'ZSH_THEME="powerlevel10k/powerlevel10k"' \
    'plugins=(git docker python zsh-autosuggestions zsh-syntax-highlighting)' \
    'export HISTFILE=/root/history/.zsh_history' \
    'export POWERLEVEL10K_DISABLE_CONFIGURATION_WIZARD=true' \
    'setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY INC_APPEND_HISTORY' \
    'source $ZSH/oh-my-zsh.sh' \
    '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh' \
    > /root/.zshrc

# Make zsh the login shell for root (won't affect Docker RUN shell)
RUN chsh -s /usr/bin/zsh root || true

# after your Oh My Zsh setup and .zshrc that sources ~/.p10k.zsh
COPY docker/p10k.zsh /root/.p10k.zsh

# Build the Huggingface cache directory
RUN mkdir -p /huggingface_cache
ENV HF_HOME="/huggingface_cache"

# Install Poetry inside the container
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

# Configure Poetry to install directly into system Python (no venv)
RUN poetry config virtualenvs.create false

# Copy project dependency descriptors
COPY pyproject.toml poetry.lock* ./

# Install dependencies using Poetry into the system environment
RUN poetry install --no-root --no-interaction --no-ansi --only main

# === Runtime Stage ===
FROM python:3.12-slim AS runtime

WORKDIR /code

# Copy installed dependencies from the builder
COPY --from=base /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Reapply the environment variables for runtime and module resolution
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="$PYTHONPATH:/code"

# Recreate history and Huggingface cache directories (so they can be mapped via Docker Compose)
RUN mkdir -p /root/history
ENV HISTFILE=/root/history/.zsh_history
ENV PROMPT_COMMAND="history -a"

RUN mkdir -p /huggingface_cache
ENV HF_HOME="/huggingface_cache"

# Copy the rest of your application code
COPY . .

# Expose your service port
EXPOSE 8000

# Final command to run your app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
