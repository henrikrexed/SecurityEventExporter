# Logging and Debugging Guide

## Overview

The OpenTelemetry Security Event Exporter includes comprehensive logging capabilities to help with debugging, monitoring, and troubleshooting. The exporter uses structured logging with different log levels to provide detailed information about its operation.

## Log Levels

The exporter supports the following log levels:

- **INFO**: General operational information
- **DEBUG**: Detailed debugging information
- **ERROR**: Error conditions and failures
- **WARN**: Warning conditions (currently not used)

## Configuration

### Setting Log Level

Configure the log level in your collector configuration using the `telemetry` section:

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

## Log Categories

### 1. Exporter Lifecycle

#### Startup
```
INFO    Creating security event logs exporter
DEBUG   Security event exporter configuration    {"endpoint": "https://api.example.com/events", "timeout": "30s", "header_count": 2, "default_attribute_count": 3}
DEBUG   Configuration validation passed
DEBUG   Created HTTP client    {"timeout": "30s"}
INFO    Successfully created security event logs exporter
INFO    Starting security event exporter    {"endpoint": "https://api.example.com/events", "timeout": "30s", "header_count": 2, "default_attribute_count": 3}
DEBUG   Security event exporter configuration    {"retry_settings": {...}, "queue_settings": {...}}
```

#### Shutdown
```
INFO    Shutting down security event exporter
DEBUG   Security event exporter shutdown completed
```

### 2. Log Processing

#### Batch Processing
```
DEBUG   Processing logs batch    {"resource_logs_count": 5}
DEBUG   Processing resource log    {"resource_index": 0, "scope_logs_count": 2}
DEBUG   Processing scope log    {"scope_index": 0, "log_records_count": 10}
```

#### Individual Log Records
```
DEBUG   Processing log record    {"log_index": 0, "severity": "ERROR", "timestamp": 1703268600}
DEBUG   Successfully converted log to security event    {"event_field_count": 15}
DEBUG   Successfully sent security event    {"successful_count": 1}
```

#### Batch Summary
```
INFO    Completed processing logs batch    {"total_resource_logs": 5, "total_log_records": 50, "successful_events": 48, "failed_events": 2}
```

### 3. Security Event Conversion

#### Default Attributes
```
DEBUG   Added default attributes    {"count": 3}
```

#### Resource Attributes
```
DEBUG   Added resource attributes    {"count": 8}
DEBUG   Added resource attribute    {"key": "resource.service.name", "value": "auth-service"}
DEBUG   Added resource attribute    {"key": "resource.host.name", "value": "server-01"}
```

#### Log Attributes
```
DEBUG   Added log attributes    {"count": 5}
DEBUG   Added log attribute    {"key": "attributes.user.id", "value": "user123"}
DEBUG   Added log attribute    {"key": "attributes.event.type", "value": "authentication_failure"}
```

#### Log Record Fields
```
DEBUG   Added log record fields    {"timestamp": "2024-01-15T10:30:00Z", "severity": "ERROR", "severity_number": 17}
```

#### Trace and Span Information
```
DEBUG   Added trace ID    {"trace_id": "1234567890abcdef1234567890abcdef"}
DEBUG   Added span ID    {"span_id": "1234567890abcdef"}
```

#### Message Body
```
DEBUG   Added string message body    {"message_preview": "Security alert: Failed login attempt for user user123 from IP 192.168.1.100"}
DEBUG   Added bytes message body    {"message_length": 1024}
DEBUG   Log body has unsupported type    {"type": "Map"}
```

#### Conversion Summary
```
DEBUG   Completed log to security event conversion    {"total_fields": 15}
```

### 4. HTTP Communication

#### Request Preparation
```
DEBUG   Starting to send security event    {"endpoint": "https://api.example.com/events", "event_field_count": 15}
DEBUG   Successfully marshaled security event to JSON    {"json_size_bytes": 1024, "json_preview": "{\"timestamp\":\"2024-01-15T10:30:00Z\",\"severity\":\"ERROR\"..."}
DEBUG   Created HTTP request    {"url": "https://api.example.com/events", "method": "POST"}
```

#### Headers
```
DEBUG   Added custom header    {"header_name": "Authorization", "is_sensitive": true}
DEBUG   Added custom header    {"header_name": "X-API-Key", "is_sensitive": true}
DEBUG   Set HTTP headers    {"total_headers": 3}
```

#### Request Execution
```
DEBUG   Sending HTTP request    {"endpoint": "https://api.example.com/events", "timeout": "30s"}
DEBUG   Received HTTP response    {"status_code": 200, "status": "200 OK", "request_duration": "150ms", "content_length": 0}
DEBUG   Successfully sent security event    {"status_code": 200, "request_duration": "150ms", "json_size_bytes": 1024}
```

### 5. Error Handling

#### Configuration Errors
```
ERROR   Invalid configuration for security event exporter    {"error": "endpoint is required"}
```

#### Conversion Errors
```
ERROR   Failed to convert log to security event    {"error": "invalid log format", "resource_index": 0, "scope_index": 0, "log_index": 5, "severity": "ERROR"}
```

#### HTTP Errors
```
ERROR   Failed to marshal security event to JSON    {"error": "invalid character", "event_field_count": 15}
ERROR   Failed to create HTTP request    {"error": "invalid URL", "endpoint": "invalid-url", "method": "POST"}
ERROR   Failed to send HTTP request    {"error": "connection refused", "endpoint": "https://api.example.com/events", "request_duration": "5s", "timeout": "30s"}
ERROR   HTTP request failed with non-success status    {"status_code": 401, "status": "401 Unauthorized", "endpoint": "https://api.example.com/events", "request_duration": "100ms"}
ERROR   HTTP error response body    {"response_body": "{\"error\":\"Invalid API key\"}"}
```

## Debugging Tips

### 1. Enable Debug Logging

For detailed debugging, set the log level to `debug`:

```yaml
service:
  telemetry:
    logs:
      level: debug
```

### 2. Monitor Batch Processing

Look for batch processing logs to understand throughput:

```
INFO    Completed processing logs batch    {"total_resource_logs": 5, "total_log_records": 50, "successful_events": 48, "failed_events": 2}
```

### 3. Check HTTP Performance

Monitor request duration and response codes:

```
DEBUG   Received HTTP response    {"status_code": 200, "status": "200 OK", "request_duration": "150ms", "content_length": 0}
```

### 4. Verify Event Structure

Check the number of fields in generated security events:

```
DEBUG   Successfully converted log to security event    {"event_field_count": 15}
```

### 5. Monitor Error Rates

Track failed events and their causes:

```
ERROR   Failed to send security event    {"error": "connection timeout", "resource_index": 0, "scope_index": 0, "log_index": 5, "endpoint": "https://api.example.com/events"}
```

## Performance Considerations

### Debug Logging Overhead

Debug logging can generate significant output and impact performance. Use it judiciously:

- **Development/Testing**: Use `debug` level for detailed troubleshooting
- **Production**: Use `info` level for operational monitoring
- **High-throughput**: Use `error` level to minimize overhead

### Log Volume

Debug logging can generate large volumes of logs. Consider:

- Log rotation and retention policies
- Centralized log aggregation
- Filtering specific log categories if needed

## Security Considerations

### Sensitive Information

The exporter identifies sensitive headers and logs them appropriately:

```
DEBUG   Added custom header    {"header_name": "Authorization", "is_sensitive": true}
```

Sensitive headers include:
- `Authorization`
- `Cookie`
- `X-API-Key`
- `X-Auth-Token`

### Log Sanitization

- Sensitive header values are not logged
- Long message bodies are truncated in debug logs
- JSON previews are limited to 200 characters

## Monitoring and Alerting

### Key Metrics to Monitor

1. **Processing Rate**: `successful_events` vs `failed_events`
2. **HTTP Performance**: `request_duration` and `status_code`
3. **Error Rate**: Frequency of error logs
4. **Throughput**: `total_log_records` per batch

### Alerting Rules

Create alerts for:
- High error rates
- HTTP failures (4xx/5xx status codes)
- Long request durations
- Processing failures

### Log Aggregation

Consider using log aggregation tools like:
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Splunk
- Grafana Loki
- Fluentd

## Troubleshooting Common Issues

### 1. High Error Rates

Check for:
- Invalid endpoint URLs
- Authentication failures
- Network connectivity issues
- Rate limiting

### 2. Slow Performance

Monitor:
- HTTP request duration
- JSON marshaling time
- Network latency
- Endpoint response times

### 3. Missing Events

Verify:
- Log processing counts
- Event conversion success
- HTTP delivery success
- Configuration validation

### 4. Memory Issues

Watch for:
- Large JSON payloads
- High batch sizes
- Memory usage in logs
- Garbage collection patterns
