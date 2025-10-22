# API Reference

## Security Event Exporter API

### Configuration Structure

```go
type Config struct {
    Endpoint          string                      `mapstructure:"endpoint"`
    Timeout           time.Duration               `mapstructure:"timeout"`
    Headers           map[string]configopaque.String `mapstructure:"headers"`
    DefaultAttributes map[string]interface{}      `mapstructure:"default_attributes"`
    RetrySettings     map[string]interface{}      `mapstructure:"retry_on_failure"`
    QueueSettings     map[string]interface{}      `mapstructure:"sending_queue"`
}
```

### Factory Function

```go
func NewFactory() exporter.Factory
```

Creates a new factory for the security event exporter.

### Exporter Interface

The exporter implements the `exporter.Logs` interface:

```go
type Logs interface {
    component.Component
    ConsumeLogs(ctx context.Context, ld plog.Logs) error
}
```

### Methods

#### `Capabilities() consumer.Capabilities`

Returns the capabilities of the exporter.

```go
func (e *securityEventExporter) Capabilities() consumer.Capabilities {
    return consumer.Capabilities{MutatesData: false}
}
```

#### `Start(ctx context.Context, host component.Host) error`

Starts the exporter.

```go
func (e *securityEventExporter) Start(ctx context.Context, host component.Host) error
```

#### `Shutdown(ctx context.Context) error`

Shuts down the exporter.

```go
func (e *securityEventExporter) Shutdown(ctx context.Context) error
```

#### `ConsumeLogs(ctx context.Context, ld plog.Logs) error`

Processes incoming logs and converts them to security events.

```go
func (e *securityEventExporter) ConsumeLogs(ctx context.Context, ld plog.Logs) error
```

### Configuration Validation

#### `Validate() error`

Validates the configuration.

```go
func (cfg *Config) Validate() error
```

Validation rules:
- `endpoint` is required and must not be empty
- `timeout` must be greater than 0 (defaults to 30s if not set)

### Helper Functions

#### `createDefaultRetrySettings() map[string]interface{}`

Creates default retry settings.

```go
func createDefaultRetrySettings() map[string]interface{} {
    return map[string]interface{}{
        "enabled":              true,
        "initial_interval":     "5s",
        "randomization_factor": 0.5,
        "multiplier":           1.5,
        "max_interval":         "30s",
        "max_elapsed_time":     "5m",
    }
}
```

#### `createDefaultQueueSettings() map[string]interface{}`

Creates default queue settings.

```go
func createDefaultQueueSettings() map[string]interface{} {
    return map[string]interface{}{
        "enabled":       true,
        "num_consumers": 10,
        "queue_size":    1000,
    }
}
```

## Security Event Format

### JSON Structure

Security events are generated as JSON objects with the following structure:

```json
{
  "timestamp": "string",           // ISO 8601 timestamp
  "severity": "string",            // Log severity level
  "severity_number": "number",     // Numeric severity level
  "message": "string",             // Log message body
  "trace_id": "string",            // OpenTelemetry trace ID (if available)
  "span_id": "string",             // OpenTelemetry span ID (if available)
  "resource.*": "string",          // Resource attributes (prefixed with "resource.")
  "attributes.*": "string"         // Log attributes (prefixed with "attributes.")
}
```

### Field Mapping

| OpenTelemetry Field | Security Event Field | Description |
|-------------------|---------------------|-------------|
| `Timestamp()` | `timestamp` | Log timestamp in ISO 8601 format |
| `SeverityText()` | `severity` | Human-readable severity level |
| `SeverityNumber()` | `severity_number` | Numeric severity level |
| `Body()` | `message` | Log message content |
| `TraceID()` | `trace_id` | OpenTelemetry trace ID |
| `SpanID()` | `span_id` | OpenTelemetry span ID |
| Resource attributes | `resource.*` | Resource attributes with prefix |
| Log attributes | `attributes.*` | Log attributes with prefix |

### Example Security Event

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "severity_number": 17,
  "message": "Security alert: Failed login attempt",
  "trace_id": "1234567890abcdef1234567890abcdef",
  "span_id": "1234567890abcdef",
  "source": "opentelemetry-collector",
  "environment": "production",
  "resource.service.name": "auth-service",
  "resource.host.name": "auth-server-01",
  "resource.k8s.pod.name": "auth-service-7d4b8c9f6-x8k2m",
  "attributes.user.id": "user123",
  "attributes.ip.address": "192.168.1.100",
  "attributes.event.type": "authentication_failure",
  "attributes.attempt.count": "3"
}
```

## HTTP Client Configuration

### Request Format

- **Method**: POST
- **Content-Type**: application/json
- **Body**: JSON-encoded security event

### Headers

Custom headers can be configured in the exporter configuration:

```yaml
exporters:
  securityevent:
    headers:
      Authorization: "Bearer your-api-token"
      X-API-Key: "your-api-key"
      X-Source: "otel-collector"
```

### Timeout

HTTP request timeout can be configured:

```yaml
exporters:
  securityevent:
    timeout: 30s
```

### Error Handling

The exporter handles HTTP errors with the following behavior:

- **2xx status codes**: Success
- **4xx/5xx status codes**: Error logged and retried (if retry is enabled)
- **Network errors**: Retried (if retry is enabled)

## Dependencies

### Required Go Modules

- `go.opentelemetry.io/collector/component v1.43.0`
- `go.opentelemetry.io/collector/config/configopaque v1.43.0`
- `go.opentelemetry.io/collector/consumer v1.43.0`
- `go.opentelemetry.io/collector/exporter v1.43.0`
- `go.opentelemetry.io/collector/pdata v1.43.0`
- `go.uber.org/zap v1.27.0`

### Indirect Dependencies

- `github.com/go-logr/logr v1.4.3`
- `github.com/go-logr/stdr v1.2.2`
- `github.com/gogo/protobuf v1.3.2`
- `github.com/hashicorp/go-version v1.7.0`
- `github.com/json-iterator/go v1.1.12`
- `github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd`
- `github.com/modern-go/reflect2 v1.0.3-0.20250322232337-35a7c28c31ee`
- `go.opentelemetry.io/auto/sdk v1.1.0`
- `go.opentelemetry.io/collector/featuregate v1.43.0`
- `go.opentelemetry.io/collector/pipeline v1.43.0`
- `go.opentelemetry.io/contrib/bridges/otelzap v0.13.0`
- `go.opentelemetry.io/otel v1.38.0`
- `go.opentelemetry.io/otel/log v0.14.0`
- `go.opentelemetry.io/otel/metric v1.38.0`
- `go.opentelemetry.io/otel/trace v1.38.0`
- `go.uber.org/multierr v1.11.0`
- `golang.org/x/net v0.42.0`
- `golang.org/x/sys v0.35.0`
- `golang.org/x/text v0.27.0`
- `google.golang.org/genproto/googleapis/rpc v0.0.0-20250804133106-a7a43d27e69b`
- `google.golang.org/grpc v1.76.0`
- `google.golang.org/protobuf v1.36.10`
