# Configuration

Complete configuration guide for the Security Event Exporter.

## Basic Configuration

```yaml
exporters:
  securityevent:
    endpoint: https://api.example.com/security-events
    headers:
      authorization: "Bearer your-api-token"
    default_attributes:
      source: "otel-collector"
      environment: "production"
```

## Configuration Options

| Option | Type | Required | Default | Description |
|--------|------|----------|---------|-------------|
| `endpoint` | string | Yes | - | HTTP endpoint for security events |
| `timeout` | duration | No | 30s | HTTP request timeout |
| `headers` | map | No | {} | Additional HTTP headers |
| `default_attributes` | map | No | {} | Default attributes for all events |
| `retry_on_failure` | map | No | {} | Retry configuration |
| `sending_queue` | map | No | {} | Queue configuration |

## Advanced Configuration

```yaml
exporters:
  securityevent:
    endpoint: https://api.example.com/security-events
    timeout: 60s
    headers:
      authorization: "Bearer your-api-token"
      content-type: "application/json"
      x-api-version: "v1"
    default_attributes:
      source: "otel-collector"
      environment: "production"
      datacenter: "us-east-1"
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
