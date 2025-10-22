# Event Batching

The Security Event Exporter implements intelligent event batching to optimize HTTP requests and improve overall throughput. This feature reduces the number of HTTP calls while maintaining low latency and high reliability.

## Batching Overview

```mermaid
graph TD
    subgraph "Log Processing"
        A[Log Records] --> B[Event Conversion]
        B --> C[Event Collection]
    end
    
    subgraph "Batch Assembly"
        C --> D[Batch Buffer]
        D --> E[Batch Ready]
    end
    
    subgraph "HTTP Delivery"
        E --> F[Single HTTP Request]
        F --> G[JSON Array Payload]
        G --> H[Security Endpoint]
    end
    
    style A fill:#e3f2fd
    style D fill:#fff3e0
    style F fill:#e8f5e8
```

## How Batching Works

### 1. Log Collection Phase

```mermaid
sequenceDiagram
    participant Collector as OTEL Collector
    participant Exporter as Security Event Exporter
    participant Buffer as Batch Buffer
    participant Converter as Event Converter
    
    Collector->>Exporter: ConsumeLogs(batch)
    Exporter->>Converter: Convert Log to Event
    Converter->>Exporter: Security Event
    Exporter->>Buffer: Add Event to Batch
    
    loop For each log in batch
        Exporter->>Converter: Convert Log to Event
        Converter->>Exporter: Security Event
        Exporter->>Buffer: Add Event to Batch
    end
    
    Exporter->>Buffer: Batch Complete
```

### 2. Batch Assembly

```mermaid
graph LR
    subgraph "Event Collection"
        A[Event 1] --> D[Batch Buffer]
        B[Event 2] --> D
        C[Event N] --> D
    end
    
    subgraph "Batch Processing"
        D --> E[Event Array]
        E --> F[JSON Serialization]
        F --> G[HTTP Request]
    end
    
    style D fill:#fff3e0
    style E fill:#e8f5e8
    style F fill:#f3e5f5
```

## Batching Benefits

### Performance Improvements

```mermaid
graph TB
    subgraph "Without Batching"
        A1[Log 1] --> B1[HTTP Request 1]
        A2[Log 2] --> B2[HTTP Request 2]
        A3[Log 3] --> B3[HTTP Request 3]
        A4[Log N] --> B4[HTTP Request N]
    end
    
    subgraph "With Batching"
        C1[Log 1] --> D[Batch Buffer]
        C2[Log 2] --> D
        C3[Log 3] --> D
        C4[Log N] --> D
        D --> E[Single HTTP Request]
    end
    
    style B1 fill:#ffcdd2
    style B2 fill:#ffcdd2
    style B3 fill:#ffcdd2
    style B4 fill:#ffcdd2
    style E fill:#c8e6c9
```

### Resource Efficiency

| Aspect | Without Batching | With Batching | Improvement |
|--------|------------------|---------------|-------------|
| HTTP Requests | N requests | 1 request | N:1 ratio |
| Network Overhead | High | Low | Significant reduction |
| Connection Pooling | Inefficient | Efficient | Better utilization |
| Throughput | Limited | High | Substantial increase |

## Batch Configuration

### Default Behavior

The exporter automatically batches all log records from a single `ConsumeLogs` call:

```yaml
exporters:
  securityevent:
    endpoint: https://api.example.com/security-events
    # Batching is automatic - no configuration needed
```

### Batch Size Limits

```mermaid
graph TD
    A[Log Batch from Collector] --> B{Batch Size Check}
    B -->|Small Batch| C[Send Immediately]
    B -->|Large Batch| D[Split if Needed]
    D --> E[Send Multiple Batches]
    
    style C fill:#c8e6c9
    style E fill:#fff3e0
```

### Memory Management

```mermaid
graph LR
    subgraph "Memory Usage"
        A[Event Objects] --> B[Batch Buffer]
        B --> C[JSON Serialization]
        C --> D[HTTP Request]
        D --> E[Memory Release]
    end
    
    style B fill:#e3f2fd
    style E fill:#c8e6c9
```

## JSON Payload Format

### Single Event Format

```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "severity": "ERROR",
  "message": "Security event detected",
  "resource.service.name": "my-service",
  "attributes.user.id": "user123"
}
```

### Batched Events Format

```json
[
  {
    "timestamp": "2024-01-15T10:30:00Z",
    "severity": "ERROR",
    "message": "Security event detected",
    "resource.service.name": "my-service",
    "attributes.user.id": "user123"
  },
  {
    "timestamp": "2024-01-15T10:30:01Z",
    "severity": "WARN",
    "message": "Suspicious activity",
    "resource.service.name": "my-service",
    "attributes.ip.address": "192.168.1.100"
  }
]
```

## Error Handling in Batches

### Batch-Level Error Handling

```mermaid
graph TD
    A[Batch Processing] --> B{HTTP Success?}
    B -->|Yes| C[All Events Exported]
    B -->|No| D[All Events Failed]
    
    D --> E[Error Logging]
    D --> F[Metrics Update]
    D --> G[Retry Logic]
    
    style C fill:#c8e6c9
    style D fill:#ffcdd2
```

### Individual Event Errors

```mermaid
graph TD
    A[Event Conversion] --> B{Conversion Success?}
    B -->|Yes| C[Add to Batch]
    B -->|No| D[Skip Event]
    
    D --> E[Log Error]
    D --> F[Update Metrics]
    
    C --> G[Continue Processing]
    
    style C fill:#c8e6c9
    style D fill:#fff3e0
```

## Performance Metrics

### Batch Metrics

```mermaid
graph LR
    subgraph "Batch Metrics"
        A[Events per Batch] --> B[Batch Size Distribution]
        C[Batch Processing Time] --> D[Throughput Metrics]
        E[HTTP Request Duration] --> F[Performance Analysis]
    end
    
    style B fill:#e3f2fd
    style D fill:#fff3e0
    style F fill:#f3e5f5
```

### Monitoring Batch Performance

```bash
# View batch metrics in logs
docker logs otel-security-exporter | grep "batch"

# Example output:
# INFO Completed processing logs batch {"total_log_records": 50, "successful_events": 48, "failed_events": 2, "http_requests": 1}
```

## Best Practices

### 1. Optimal Batch Sizes

```mermaid
graph TB
    A[Small Batches] --> B[Low Latency]
    C[Large Batches] --> D[High Throughput]
    
    E[Optimal Range] --> F[Balanced Performance]
    
    style B fill:#c8e6c9
    style D fill:#fff3e0
    style F fill:#e3f2fd
```

### 2. Network Considerations

- **Bandwidth**: Larger batches reduce network overhead
- **Latency**: Smaller batches provide lower latency
- **Reliability**: Batches provide atomic delivery

### 3. Memory Management

```mermaid
graph LR
    A[Event Collection] --> B[Memory Allocation]
    B --> C[Batch Assembly]
    C --> D[HTTP Transmission]
    D --> E[Memory Release]
    
    style B fill:#fff3e0
    style E fill:#c8e6c9
```

## Troubleshooting

### Common Issues

1. **Large Memory Usage**: Monitor batch sizes and adjust collector configuration
2. **High Latency**: Check network connectivity and endpoint performance
3. **Batch Failures**: Verify endpoint configuration and authentication

### Debug Mode

Enable debug logging to monitor batch behavior:

```yaml
service:
  telemetry:
    logs:
      level: debug
```

### Performance Tuning

```mermaid
graph TD
    A[Monitor Metrics] --> B[Identify Bottlenecks]
    B --> C[Adjust Configuration]
    C --> D[Test Performance]
    D --> E{Improved?}
    E -->|Yes| F[Deploy Changes]
    E -->|No| A
    
    style F fill:#c8e6c9
```

## Configuration Examples

### High Throughput Configuration

```yaml
exporters:
  securityevent:
    endpoint: https://api.example.com/security-events
    timeout: 30s
    headers:
      authorization: "Bearer token"
    default_attributes:
      source: "high-throughput-collector"

processors:
  batch:
    timeout: 5s
    send_batch_size: 1000
    send_batch_max_size: 2000

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [securityevent]
```

### Low Latency Configuration

```yaml
exporters:
  securityevent:
    endpoint: https://api.example.com/security-events
    timeout: 5s
    headers:
      authorization: "Bearer token"

processors:
  batch:
    timeout: 1s
    send_batch_size: 10
    send_batch_max_size: 50

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [securityevent]
```
