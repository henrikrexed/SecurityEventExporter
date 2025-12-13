# OpenTelemetry Security Event Exporter v1.0.0

## 🎉 First Stable Release

This is the first stable release of the OpenTelemetry Security Event Exporter, a custom exporter for the OpenTelemetry Collector that transforms logs into structured security events.

## ✨ Features

### Core Functionality
- **Security Event Exporter**: Transforms OpenTelemetry logs into structured security events as JSON payloads
- **Event Batching**: Efficiently batches multiple events in a single HTTP POST request for optimal performance
- **Telemetry Metrics**: Built-in metrics for monitoring:
  - Logs received count
  - Events exported count
  - Events failed count
  - Conversion errors count
  - HTTP requests count and durations
  - HTTP errors count
- **Comprehensive Logging**: Debug and error logging enabled via OpenTelemetry telemetry with configurable log levels
- **Production Ready**: Includes retry logic, error handling, timeout management, and comprehensive testing

### Configuration Options
- **HTTP Endpoint Configuration**: Configurable endpoint for security event delivery
- **Custom Headers**: Support for API tokens and custom HTTP headers (e.g., Authorization, X-API-Key)
- **Default Attributes**: Add default attributes to all security events
- **Timeout Management**: Configurable HTTP request timeout (default: 30 seconds)
- **Retry Settings**: Configurable retry behavior for failed requests
- **Queue Settings**: Configurable queue behavior for batching

### Data Transformation
- Converts OpenTelemetry log records to security event format
- Preserves resource attributes (prefixed with `resource.`)
- Preserves log attributes (prefixed with `attributes.`)
- Includes trace and span context when available
- Includes severity information and timestamps
- Supports both string and byte message bodies

## 📦 Installation

### As a Go Module Dependency

To use this exporter in your OpenTelemetry Collector build, add it to your `go.mod`:

```bash
go get github.com/henrikrexed/SecurityEventExporter@v1.0.0
```

Or add directly to your `go.mod`:
```go
require github.com/henrikrexed/SecurityEventExporter v1.0.0
```

### Using in OCB Manifest

Add to your `ocb.yaml` to build a custom collector:

```yaml
exporters:
  - gomod: github.com/henrikrexed/SecurityEventExporter v1.0.0
```

### Docker Image

Pull the pre-built multi-architecture Docker image:

```bash
docker pull ghcr.io/henrikrexed/securityeventexporter:v1.0.0
```

Available tags:
- `v1.0.0` - Specific version
- `1.0` - Minor version
- `1` - Major version

## 📚 Documentation

- **Live Documentation**: [https://henrikrexed.github.io/SecurityEventExporter/](https://henrikrexed.github.io/SecurityEventExporter/)
- **API Reference**: [docs/API.md](https://github.com/henrikrexed/SecurityEventExporter/blob/main/docs/API.md)
- **Deployment Guide**: [docs/DEPLOYMENT.md](https://github.com/henrikrexed/SecurityEventExporter/blob/main/docs/DEPLOYMENT.md)
- **Metrics Guide**: [docs/METRICS.md](https://github.com/henrikrexed/SecurityEventExporter/blob/main/docs/METRICS.md)
- **Logging Guide**: [docs/LOGGING.md](https://github.com/henrikrexed/SecurityEventExporter/blob/main/docs/LOGGING.md)

## 🔧 Configuration Example

```yaml
exporters:
  securityevent:
    endpoint: "https://api.example.com/security-events"
    timeout: 30s
    headers:
      Authorization: "Bearer ${API_TOKEN}"
      X-API-Key: "${API_KEY}"
    default_attributes:
      source: "opentelemetry-collector"
      environment: "production"
    retry_on_failure:
      enabled: true
      initial_interval: 5s
      max_interval: 30s
      max_elapsed_time: 5m
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 1000
```

## 🏗️ Architecture

The exporter is built using:
- **Go 1.24+**: Modern Go with latest features
- **OpenTelemetry Collector v0.137.0**: Compatible with collector components
- **Structured Logging**: Uses `go.uber.org/zap` for logging
- **HTTP Client**: Standard library HTTP client with configurable timeout

## 🔒 Security Features

- Support for API tokens via custom headers
- Configurable timeout to prevent hanging requests
- Error handling and logging without exposing sensitive data
- SBOM (Software Bill of Materials) attached to release for supply chain security

## 🧪 Testing

The release includes:
- Unit tests for configuration validation
- Unit tests for exporter functionality
- Mock-based testing for HTTP interactions
- Test coverage for error scenarios

## 📋 SBOMs

Software Bill of Materials (SBOMs) are attached to this release:
- **Go Module SBOM** (`sbom-go.spdx.json`): Complete dependency tree for the Go module
- **Docker Image SBOM** (`sbom-docker.spdx.json`): Complete dependency tree for the Docker image

These SBOMs provide transparency into all components and dependencies for supply chain security.

## 🚀 Getting Started

1. **Add to your OCB manifest**:
   ```yaml
   exporters:
     - gomod: github.com/henrikrexed/SecurityEventExporter v1.0.0
   ```

2. **Configure in collector config**:
   ```yaml
   export:
     logs:
       - securityevent
   ```

3. **Build your collector**:
   ```bash
   ocb --config=ocb.yaml
   ```

## 🤝 Contributing

We welcome contributions! Please see our documentation for:
- Development setup
- Code style guidelines
- Testing requirements
- Pull request process

## 📝 Changelog

### v1.0.0 (Initial Release)
- ✅ Initial implementation of security event exporter
- ✅ Event batching support
- ✅ Telemetry metrics
- ✅ Comprehensive logging
- ✅ Docker multi-architecture support
- ✅ Complete documentation
- ✅ Unit tests
- ✅ SBOM generation
- ✅ CI/CD workflows
- ✅ Security scanning integration

## 🔗 Links

- **GitHub Repository**: [https://github.com/henrikrexed/SecurityEventExporter](https://github.com/henrikrexed/SecurityEventExporter)
- **Docker Hub**: `ghcr.io/henrikrexed/securityeventexporter`
- **Issues**: [https://github.com/henrikrexed/SecurityEventExporter/issues](https://github.com/henrikrexed/SecurityEventExporter/issues)

---

**Full Changelog**: This is the first release. See the repository for complete development history.




