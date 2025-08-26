# syntax=docker/dockerfile:1

ARG RUST_VERSION=1.82.0
ARG APP_NAME=redis_utils

################################################################################
# Stage 1: Build the application with optimizations
FROM rust:${RUST_VERSION}-slim-bullseye AS build
ARG APP_NAME

# Install necessary build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set performance-optimized environment variables
ENV RUSTFLAGS="-C target-cpu=native -C opt-level=3 -C codegen-units=1 -C panic=abort"
ENV RUST_BACKTRACE=0

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . /app/redisutils

# Ensure the library builds correctly
WORKDIR /app/redisutils

RUN cargo test --locked --release && \
    cargo build --locked --release

################################################################################
# Stage 2: Create a smaller runtime image
FROM debian:bullseye-slim AS runtime

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libc6 \
    net-tools \
    procps \
    libssl-dev \
    ca-certificates \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Create the health check script
RUN echo '#!/bin/sh' > /usr/local/bin/health_check.sh \
&& echo 'if ! redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping | grep -q "PONG"; then exit 1; fi' >> /usr/local/bin/health_check.sh \
&& chmod +x /usr/local/bin/health_check.sh

# Create the liveness probe script
RUN echo '#!/bin/sh' > /usr/local/bin/liveness_check.sh \
&& echo 'if ! redis-cli -h $REDIS_HOST -p $REDIS_PORT -a $REDIS_PASSWORD ping | grep -q "PONG"; then exit 1; fi' >> /usr/local/bin/liveness_check.sh \
&& chmod +x /usr/local/bin/liveness_check.sh

# Create a non-privileged user to run the app
ARG UID=10001
RUN adduser --disabled-password --gecos "" --home "/nonexistent" --shell "/sbin/nologin" --no-create-home --uid "${UID}" appuser

EXPOSE 443

# Switch to non-privileged user
USER appuser

# For utility library, default to shell
CMD ["/bin/bash"]
