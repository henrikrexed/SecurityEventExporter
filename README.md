# OpenTelemetry Security Event Exporter

<div align="center">

![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-Collector-orange?style=for-the-badge&logo=opentelemetry)
![Go](https://img.shields.io/badge/Go-1.24-blue?style=for-the-badge&logo=go)
![Docker](https://img.shields.io/badge/Docker-Supported-blue?style=for-the-badge&logo=docker)
![License](https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-lightgrey?style=for-the-badge)

**A custom OpenTelemetry Collector exporter that transforms logs into security events**

[Documentation](docs/) • [API Reference](docs/API.md) • [Deployment Guide](docs/DEPLOYMENT.md) • [Examples](examples/)

</div>

---

## 🔍 Overview

The Security Event Exporter converts OpenTelemetry log records into security events in JSON format and sends them to a configurable HTTP endpoint. It's particularly useful for:

- Security monitoring and alerting
- SIEM integration
- Compliance reporting
- Security event correlation

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Security Event Format](#security-event-format)
- [Telemetry Metrics](#telemetry-metrics)
- [Logging and Debugging](#logging-and-debugging)
- [Development](#development)
- [API Reference](#api-reference)
- [Deployment](#deployment)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## Features

- **Log to Security Event Transformation**: Converts OpenTelemetry logs to structured security events
- **HTTP Endpoint Support**: Configurable HTTP endpoint for security event delivery
- **Custom Headers**: Support for API tokens and custom headers
- **Default Attributes**: Configurable default attributes for all security events
- **Retry Logic**: Built-in retry mechanism for failed requests
- **Queue Management**: Configurable queue settings for high-throughput scenarios
- **Event Batching**: Efficiently batches multiple security events into single HTTP POST requests
- **Telemetry Metrics**: Comprehensive metrics for monitoring logs received, events exported, and HTTP performance
- **Docker Support**: Pre-built Docker image with OpenTelemetry Collector

## Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Log Sources   │───▶│  OTEL Collector  │───▶│ Security Event  │
│                 │    │  with Security   │    │     Exporter    │
│ • Applications  │    │  Event Exporter  │    │                 │
│ • Infrastructure│    │                  │    │ • JSON Format   │
│ • Kubernetes    │    │ • Receivers      │    │ • HTTP Delivery │
└─────────────────┘    │ • Processors     │    │ • Custom Headers│
                       │ • Exporters      │    └─────────────────┘
                       └──────────────────┘
```

## Quick Start

### Using Docker

1. **Pull the pre-built image:**
   ```bash
   docker pull hrexed/otel-collector-sec-event:dev
   ```

2. **Run the collector:**
   ```bash
   docker run -d \
     --name otel-security-collector \
     -p 4317:4317 \
     -p 4318:4318 \
     -p 8888:8888 \
     -p 8889:8889 \
     -p 13133:13133 \
     hrexed/otel-collector-sec-event:dev
   ```

### Building from Source

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd SecurityEventExporter
   ```

2. **Build the Docker image:**
   ```bash
   make docker-build
   ```

3. **Run the collector:**
   ```bash
   make run
   ```

## Configuration

### Security Event Exporter Configuration

```yaml
exporters:
  securityevent:
    endpoint: "https://your-security-endpoint.com/events"
    timeout: 30s
    headers:
      Authorization: "Bearer your-api-token"
      Content-Type: "application/json"
    default_attributes:
      source: "opentelemetry-collector"
      environment: "production"
    retry_on_failure:
      enabled: true
      initial_interval: 5s
      randomization_factor: 0.5
      multiplier: 1.5
      max_interval: 30s
      max_elapsed_time: 5m
    sending_queue:
      enabled: true
      num_consumers: 10
      queue_size: 1000
```

### Complete Collector Configuration

See `collector-config.yaml` for a complete example configuration that includes:

- **Receivers**: OTLP, File Log, Kubernetes Objects
- **Processors**: Memory Limiter, Batch, Tail Sampling, Filter, Resource, Transform, Cumulative to Delta
- **Exporters**: OTLP, Debug, Security Event

## Security Event Format

The exporter transforms OpenTelemetry log records into security events with the following structure:

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "severity_number": 17,
  "message": "Security alert: Failed login attempt",
  "source": "opentelemetry-collector",
  "environment": "production",
  "trace_id": "1234567890abcdef1234567890abcdef",
  "span_id": "1234567890abcdef",
  "resource.service.name": "auth-service",
  "resource.host.name": "auth-server-01",
  "attributes.user.id": "user123",
  "attributes.ip.address": "192.168.1.100",
  "attributes.event.type": "authentication_failure"
}
```

## Telemetry Metrics

The Security Event Exporter provides comprehensive telemetry metrics to monitor its performance and operational status. These metrics help you understand the exporter's behavior, identify potential issues, and optimize performance.

### Key Metrics

- **Logs Received**: Total number of log records received from the OpenTelemetry Collector
- **Events Exported**: Total number of security events successfully exported
- **Events Failed**: Total number of security events that failed to be exported
- **Conversion Errors**: Total number of log records that failed to convert to security events
- **HTTP Requests**: Total number of HTTP requests sent to the security event endpoint
- **HTTP Errors**: Total number of HTTP requests that failed
- **HTTP Performance**: Request duration statistics for performance analysis

### Event Batching

The exporter efficiently batches multiple security events into single HTTP POST requests, reducing the number of HTTP calls and improving overall throughput. All log records from a single batch are collected, converted to security events, and sent together as a JSON array.

### Metrics Collection

All metrics are reported through structured logging at key lifecycle events:
- **Startup**: Initial metrics state
- **Batch Processing**: Real-time metrics during log processing
- **Shutdown**: Final metrics summary with performance statistics

For detailed information about metrics collection, monitoring, and troubleshooting, see the [Telemetry Metrics Guide](docs/METRICS.md).

## Logging and Debugging

The Security Event Exporter includes comprehensive logging capabilities to help with debugging, monitoring, and troubleshooting.

### Log Levels

Configure the log level in your collector configuration:

```yaml
service:
  telemetry:
    logs:
      level: debug  # Options: debug, info, warn, error
    metrics:
      address: 0.0.0.0:8888
```

### Environment Variable

You can also set the log level using an environment variable:

```bash
export OTEL_LOG_LEVEL=debug
```

### Log Categories

The exporter provides detailed logging for:

- **Exporter Lifecycle**: Startup, shutdown, and configuration
- **Log Processing**: Batch processing and individual log record handling
- **Security Event Conversion**: Field mapping and transformation details
- **HTTP Communication**: Request/response details and performance metrics
- **Error Handling**: Detailed error information with context

### Example Log Output

```
INFO    Starting security event exporter    {"endpoint": "https://api.example.com/events", "timeout": "30s"}
DEBUG   Processing logs batch    {"resource_logs_count": 5}
DEBUG   Successfully converted log to security event    {"event_field_count": 15}
DEBUG   Successfully sent security event    {"status_code": 200, "request_duration": "150ms"}
INFO    Completed processing logs batch    {"total_log_records": 50, "successful_events": 48, "failed_events": 2}
```

### Debug Mode

For detailed debugging, enable debug logging to see:
- Individual log record processing
- Security event field mapping
- HTTP request/response details
- Performance metrics
- Error context and troubleshooting information

For more detailed information, see the [Logging and Debugging Guide](docs/LOGGING.md).

## Development

### Prerequisites

- Go 1.24+
- Docker or Podman
- Make

### Project Structure

```
SecurityEventExporter/
├── exporter/              # Exporter implementation
│   ├── config.go         # Configuration structure
│   └── exporter.go       # Main exporter logic
├── manifests/            # OCB configuration
│   └── ocb.yaml         # OpenTelemetry Collector Builder manifest
├── collector-config.yaml # Collector configuration
├── example-config.yaml   # Example configuration
├── Dockerfile           # Docker build configuration
├── Makefile            # Build automation
├── go.mod              # Go module dependencies
└── README.md           # This file
```

### Building

```bash
# Build Go module
make build

# Run tests
make test

# Build Docker image
make docker-build

# Build for specific platform
make docker-build PLATFORM=linux/arm64
```

### Testing

```bash
# Run unit tests
make test

# Test with Docker Compose
docker-compose up --build
```

## API Reference

### Configuration Options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `endpoint` | string | Required | HTTP endpoint for security events |
| `timeout` | duration | 30s | HTTP request timeout |
| `headers` | map[string]string | {} | Custom HTTP headers |
| `default_attributes` | map[string]interface{} | {} | Default attributes for all events |
| `retry_on_failure` | object | See below | Retry configuration |
| `sending_queue` | object | See below | Queue configuration |

### Retry Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | true | Enable retry logic |
| `initial_interval` | duration | 5s | Initial retry interval |
| `randomization_factor` | float | 0.5 | Randomization factor |
| `multiplier` | float | 1.5 | Backoff multiplier |
| `max_interval` | duration | 30s | Maximum retry interval |
| `max_elapsed_time` | duration | 5m | Maximum total retry time |

### Queue Configuration

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `enabled` | bool | true | Enable sending queue |
| `num_consumers` | int | 10 | Number of consumer goroutines |
| `queue_size` | int | 1000 | Queue buffer size |

## Deployment

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-security-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: otel-security-collector
  template:
    metadata:
      labels:
        app: otel-security-collector
    spec:
      containers:
      - name: otel-collector
        image: hrexed/otel-collector-sec-event:dev
        ports:
        - containerPort: 4317
        - containerPort: 4318
        - containerPort: 8888
        - containerPort: 8889
        - containerPort: 13133
        volumeMounts:
        - name: config
          mountPath: /otel/collector-config.yaml
          subPath: collector-config.yaml
      volumes:
      - name: config
        configMap:
          name: otel-config
```

### Docker Compose

```yaml
version: '3.8'
services:
  otel-collector:
    image: hrexed/otel-collector-sec-event:dev
    ports:
      - "4317:4317"
      - "4318:4318"
      - "8888:8888"
      - "8889:8889"
      - "13133:13133"
    volumes:
      - ./collector-config.yaml:/otel/collector-config.yaml
    environment:
      - OTEL_LOG_LEVEL=info
```

## Monitoring

### Health Check

The collector exposes a health check endpoint at `http://localhost:13133/`:

```bash
curl http://localhost:13133/
```

### Metrics

The collector exposes Prometheus metrics at `http://localhost:8888/metrics`:

```bash
curl http://localhost:8888/metrics
```

### Logs

View collector logs:

```bash
docker logs otel-security-collector
```

## Troubleshooting

### Common Issues

1. **Connection Refused**: Check if the endpoint URL is correct and accessible
2. **Authentication Failed**: Verify API tokens and headers configuration
3. **High Memory Usage**: Adjust queue size and number of consumers
4. **Slow Performance**: Check network latency and endpoint response times

### Debug Mode

Enable debug logging:

```yaml
service:
  telemetry:
    logs:
      level: debug
```

### Performance Tuning

For high-throughput scenarios:

```yaml
exporters:
  securityevent:
    sending_queue:
      num_consumers: 20
      queue_size: 5000
    retry_on_failure:
      max_elapsed_time: 10m
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Support

For support and questions:

- Create an issue in the repository
- Check the troubleshooting section
- Review the OpenTelemetry documentation

## Changelog

### v1.0.0
- Initial release
- Security event exporter implementation
- Docker image support
- Comprehensive configuration options