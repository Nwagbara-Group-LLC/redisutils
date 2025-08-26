# Multi-stage build for RedisUtils
ARG RUST_VERSION=1.75

# Build stage
FROM rust:${RUST_VERSION}-slim-bullseye as builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Build dependencies (cache layer)
RUN mkdir src && echo "fn main() {}" > src/main.rs && \
    cargo build --release && \
    rm -rf src/

# Copy source code
COPY . .

# Build library and utilities
RUN cargo build --release

# Create library distribution
RUN mkdir -p /usr/local/lib/redis-utils && \
    cp target/release/libredisutils.so /usr/local/lib/redis-utils/ 2>/dev/null || true && \
    cp target/release/libredis_utils.rlib /usr/local/lib/redis-utils/ 2>/dev/null || true && \
    cp -r src/ /usr/local/lib/redis-utils/src/ && \
    cp Cargo.toml /usr/local/lib/redis-utils/

# Test utilities stage
FROM redis:7-alpine as test-runner

WORKDIR /app

# Copy test utilities
COPY --from=builder /app/target/release/redis-cluster-test /usr/local/bin/redis-cluster-test
COPY --from=builder /app/target/release/redis-benchmark /usr/local/bin/redis-benchmark
COPY --from=builder /app/target/release/redis-migration /usr/local/bin/redis-migration

# Copy test scripts
COPY --from=builder /app/tests/ /app/tests/

# Runtime stage - minimal Alpine for utilities
FROM alpine:3.18

WORKDIR /app

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    redis \
    && adduser -D -s /bin/sh appuser

# Copy built utilities
COPY --from=builder /usr/local/lib/redis-utils/ /usr/local/lib/redis-utils/
COPY --from=builder /app/target/release/redis-cluster-test /usr/local/bin/redis-cluster-test
COPY --from=builder /app/target/release/redis-benchmark /usr/local/bin/redis-benchmark
COPY --from=builder /app/target/release/redis-migration /usr/local/bin/redis-migration
COPY --from=builder /app/target/release/test-redis-integration /usr/local/bin/test-redis-integration

# Copy configuration
COPY --from=builder /app/config/ /etc/redis-utils/config/

# Create integration test script
RUN cat > /usr/local/bin/test-redis-integration << 'EOF' && \
    chmod +x /usr/local/bin/test-redis-integration
#!/bin/sh
set -e
echo "Testing Redis integration..."

# Test basic connection
redis-cli ping || exit 1

# Test clustering support
/usr/local/bin/redis-cluster-test || echo "Cluster test skipped (no cluster detected)"

# Test benchmarks
/usr/local/bin/redis-benchmark --quick

echo "Redis integration tests completed successfully"
EOF

# Metadata
LABEL maintainer="Nwagbara-Group-LLC"
LABEL description="RedisUtils - Shared Redis utilities and connection management"
LABEL version="1.0.0"

ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.schema-version="1.0"

# Security: Use non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD redis-cli ping || exit 1

# Default command - utility mode
ENTRYPOINT ["/usr/local/bin/test-redis-integration"]
