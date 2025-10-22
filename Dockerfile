# Multi-stage Dockerfile for OpenTelemetry Collector with Security Event Exporter

# Build stage
FROM golang:1.24-alpine AS builder

# Set build arguments
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# Install build dependencies
RUN apk add --no-cache git make

# Set working directory
WORKDIR /app

# Copy go mod files
COPY go.mod ./

# Download dependencies
RUN go mod download

# Copy source code
COPY . .

# Install OCB and generate collector
RUN go install go.opentelemetry.io/collector/cmd/builder@v0.137.0
RUN mkdir -p dist

# Try full OCB build with debug output
RUN builder --config=manifests/ocb.yaml --skip-strict-versioning
RUN echo "=== Build completed ===" && ls -la dist/

# Runtime stage
FROM alpine:3.22

# Install runtime dependencies
RUN apk add --no-cache ca-certificates tzdata

# Create non-root user
RUN addgroup -g 10001 -S otelcol && \
    adduser -u 10001 -S otelcol -G otelcol

# Set working directory
WORKDIR /otel

# Copy the built collector binary
COPY --from=builder /app/dist/otelcol-security /otel/otelcol-security

# Copy default configuration
COPY --from=builder /app/collector-config.yaml /otel/collector-config.yaml

# Set ownership
RUN chown -R otelcol:otelcol /otel

# Switch to non-root user
USER otelcol

# Expose ports
EXPOSE 4317 4318 8888 8889 13133

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:13133/ || exit 1

# Default command
ENTRYPOINT ["/otel/otelcol-security"]
CMD ["--config", "/otel/collector-config.yaml"]

# Labels
LABEL maintainer="OpenTelemetry Security Event Exporter"
LABEL description="OpenTelemetry Collector with Security Event Exporter"
LABEL version="1.0.0"
