FROM mcr.microsoft.com/devcontainers/python:3.13-bookworm

# Install pip for Python 3.13
RUN python -m pip install --upgrade pip

# Install DevTunnel CLI
RUN curl -sL https://aka.ms/DevTunnelCliInstall | bash && \
    cp /root/bin/devtunnel /usr/local/bin/devtunnel


# Install the packages required for development
COPY requirements-dev.txt .
COPY src/python/requirements.txt src/python/
COPY database/data-generator/requirements.txt database/data-generator/
RUN pip install -r requirements-dev.txt

ENV ENVIRONMENT=container
