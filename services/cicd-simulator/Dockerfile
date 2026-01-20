FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install yamllint via pip for YAML validation
COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Create simulator directory
RUN mkdir -p /app/simulator
WORKDIR /app

# Copy simulator code
COPY simulator/ /app/simulator/

# Make CLI accessible
ENV PYTHONPATH=/app

# Create entrypoint script
RUN echo '#!/bin/bash\npython -m simulator.cli "$@"' > /usr/local/bin/cicd-sim && \
    chmod +x /usr/local/bin/cicd-sim

# Keep container running
CMD ["tail", "-f", "/dev/null"]
