# Security Event Format

The Security Event Exporter transforms OpenTelemetry log records into structured security events in JSON format.

## Event Structure

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "severity_number": 17,
  "message": "Security event detected: unauthorized access attempt",
  "resource.service.name": "my-security-service",
  "resource.service.version": "1.0.0",
  "attributes.user.id": "user123",
  "attributes.ip.address": "192.168.1.100",
  "attributes.event.type": "authentication_failure",
  "trace_id": "12345678901234567890123456789012",
  "span_id": "1234567890123456"
}
```

## Field Mapping

| Source | Target Field | Description |
|--------|--------------|-------------|
| Log timestamp | `timestamp` | ISO 8601 formatted timestamp |
| Log severity | `severity` | Severity text (DEBUG, INFO, WARN, ERROR, FATAL) |
| Log severity number | `severity_number` | Numeric severity level |
| Log body | `message` | Log message content |
| Resource attributes | `resource.*` | Prefixed with "resource." |
| Log attributes | `attributes.*` | Prefixed with "attributes." |
| Trace ID | `trace_id` | OpenTelemetry trace ID (if available) |
| Span ID | `span_id` | OpenTelemetry span ID (if available) |
| Default attributes | Custom fields | Added as-is from configuration |

## Event Types

### Authentication Events

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "message": "Authentication failed for user",
  "attributes.user.id": "user123",
  "attributes.ip.address": "192.168.1.100",
  "attributes.event.type": "authentication_failure",
  "attributes.failure.reason": "invalid_password"
}
```

### Authorization Events

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "WARN",
  "message": "Access denied to resource",
  "attributes.user.id": "user123",
  "attributes.resource.path": "/admin/users",
  "attributes.event.type": "authorization_failure",
  "attributes.permission.required": "admin:users:read"
}
```

### Network Security Events

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "message": "Suspicious network activity detected",
  "attributes.ip.address": "192.168.1.100",
  "attributes.port": 8080,
  "attributes.event.type": "network_intrusion",
  "attributes.threat.level": "high"
}
```
