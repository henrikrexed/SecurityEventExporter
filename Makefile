# OpenTelemetry Security Event Exporter Makefile

# Variables
BINARY_NAME := security-event-exporter
COLLECTOR_BINARY := otelcol-security

# Platform and Architecture
PLATFORM ?= linux
ARCH ?= amd64
GOOS ?= $(PLATFORM)
GOARCH ?= $(ARCH)

# Container runtime (docker or podman)
CONTAINER_RUNTIME ?= docker

# Release version
RELEASE_VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
DOCKER_TAG ?= $(RELEASE_VERSION)

# Docker image configuration
DOCKER_REGISTRY ?= hrexed
DOCKER_IMAGE_NAME ?= otel-collector-sec-event
DOCKER_IMAGE := $(DOCKER_REGISTRY)/$(DOCKER_IMAGE_NAME)
DOCKER_FULL_TAG := $(DOCKER_IMAGE):$(DOCKER_TAG)

# OCB and Go versions
OCB_VERSION := 0.108.0
GO_VERSION := 1.24

# Directories
BUILD_DIR := build
DIST_DIR := dist
MANIFEST_DIR := manifests

# Go build flags
LDFLAGS := -ldflags "-X main.version=$(RELEASE_VERSION) -X main.buildDate=$(shell date -u +%Y-%m-%dT%H:%M:%SZ)"

.PHONY: all build test clean docker-build docker-push help

# Default target
all: test build

# Help target
help:
	@echo "Available targets:"
	@echo "  build          - Build the security event exporter"
	@echo "  test           - Run unit tests"
	@echo "  test-coverage  - Run tests with coverage"
	@echo "  clean          - Clean build artifacts"
	@echo "  docker-build   - Build Docker image with OCB"
	@echo "  docker-buildx  - Build multi-platform Docker image"
	@echo "  docker-push     - Push Docker image to registry"
	@echo "  all            - Run test and build"
	@echo ""
	@echo "Platform targets:"
	@echo "  build-amd64    - Build for AMD64 architecture"
	@echo "  build-arm64    - Build for ARM64 architecture"
	@echo "  docker-amd64   - Build Docker image for AMD64"
	@echo "  docker-arm64   - Build Docker image for ARM64"
	@echo ""
	@echo "Variables:"
	@echo "  PLATFORM       - Target platform (default: linux)"
	@echo "  ARCH           - Target architecture (default: amd64)"
	@echo "  CONTAINER_RUNTIME - Container runtime (default: docker)"
	@echo "  RELEASE_VERSION   - Release version (default: git tag)"
	@echo "  DOCKER_REGISTRY   - Docker registry (default: hrexed)"
	@echo "  DOCKER_IMAGE_NAME - Docker image name (default: otel-collector-sec-event)"


# Run tests
test:
	@echo "Running tests..."
	go test -v ./...

# Run tests with coverage
test-coverage:
	@echo "Running tests with coverage..."
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

# Build the exporter
build: test
	@echo "Building security event exporter..."
	@mkdir -p $(BUILD_DIR)
	go build $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) .

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -rf $(DIST_DIR)
	rm -rf $(MANIFEST_DIR)
	rm -f coverage.out coverage.html

# Build Docker image (OCB runs inside Docker)
docker-build:
	@echo "Building Docker image for $(GOOS)/$(GOARCH)..."
	@echo "Using $(CONTAINER_RUNTIME) runtime"
	@echo "Image: $(DOCKER_FULL_TAG)"
	$(CONTAINER_RUNTIME) build \
		--platform $(GOOS)/$(GOARCH) \
		--build-arg TARGETOS=$(GOOS) \
		--build-arg TARGETARCH=$(GOARCH) \
		-t $(DOCKER_FULL_TAG) \
		-t $(DOCKER_IMAGE):latest \
		-f Dockerfile .
	@echo "Docker image built: $(DOCKER_FULL_TAG)"

# Build multi-platform Docker image
docker-buildx:
	@echo "Building multi-platform Docker image..."
	@echo "Using $(CONTAINER_RUNTIME) buildx"
	$(CONTAINER_RUNTIME) buildx build \
		--platform linux/amd64,linux/arm64 \
		-t $(DOCKER_FULL_TAG) \
		-t $(DOCKER_IMAGE):latest \
		-f Dockerfile . \
		--push

# Push Docker image
docker-push: docker-build
	@echo "Pushing Docker image using $(CONTAINER_RUNTIME)..."
	$(CONTAINER_RUNTIME) push $(DOCKER_FULL_TAG)
	$(CONTAINER_RUNTIME) push $(DOCKER_IMAGE):latest

# Development targets
dev-setup:
	@echo "Setting up development environment..."
	go mod tidy
	go mod download

# Lint code
lint:
	@echo "Running linter..."
	golangci-lint run

# Format code
fmt:
	@echo "Formatting code..."
	go fmt ./...

# Security scan
security:
	@echo "Running security scan..."
	gosec ./...

# Full CI pipeline
ci: clean fmt lint test-coverage security build docker-build
	@echo "CI pipeline completed successfully"

# Platform-specific build targets
build-amd64:
	@$(MAKE) build ARCH=amd64

build-arm64:
	@$(MAKE) build ARCH=arm64

docker-amd64:
	@$(MAKE) docker-build ARCH=amd64

docker-arm64:
	@$(MAKE) docker-build ARCH=arm64

# Podman-specific targets
podman-build:
	@$(MAKE) docker-build CONTAINER_RUNTIME=podman

podman-push:
	@$(MAKE) docker-push CONTAINER_RUNTIME=podman

# Release targets
release: clean test docker-buildx
	@echo "Release $(RELEASE_VERSION) completed successfully"

release-local: clean test docker-build docker-push
	@echo "Local release $(RELEASE_VERSION) completed successfully"

# Show version info
version:
	@echo "Binary: $(BINARY_NAME)"
	@echo "Collector: $(COLLECTOR_BINARY)"
	@echo "Platform: $(GOOS)/$(GOARCH)"
	@echo "Container Runtime: $(CONTAINER_RUNTIME)"
	@echo "Docker Image: $(DOCKER_FULL_TAG)"
	@echo "Release Version: $(RELEASE_VERSION)"
	@echo "OCB Version: $(OCB_VERSION)"
	@echo "Go Version: $(GO_VERSION)"
