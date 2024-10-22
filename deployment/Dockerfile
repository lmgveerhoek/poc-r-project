# Start with the Rocker base image
FROM rocker/r-base:4.4.1

# Install dependencies for building Python and pyenv
RUN apt-get update && apt-get install -y --no-install-recommends \
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install pyenv
RUN curl https://pyenv.run | bash

# Add pyenv to PATH
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH

# Install Python 3.11 using pyenv
RUN pyenv install 3.11.0 \
    && pyenv global 3.11.0 \
    && pyenv rehash

# Upgrade pip
RUN pip install --no-cache-dir --upgrade pip

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["sh", "-c", "mlflow models serve -m models:/${MODEL_NAME}@${MODEL_ALIAS} -p 8000 --host 0.0.0.0"]
