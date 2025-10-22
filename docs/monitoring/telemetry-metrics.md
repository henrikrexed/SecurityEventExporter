# Telemetry Metrics

The Security Event Exporter provides comprehensive telemetry metrics to monitor its performance and operational status. These metrics help you understand the exporter's behavior, identify potential issues, and optimize performance.

## Metrics Overview

```mermaid
graph TB
    subgraph "Input Metrics"
        A[Logs Received] --> B[Conversion Process]
    end
    
    subgraph "Processing Metrics"
        B --> C[Events Exported]
        B --> D[Conversion Errors]
    end
    
    subgraph "Output Metrics"
        C --> E[HTTP Requests]
        E --> F[HTTP Success]
        E --> G[HTTP Errors]
    end
    
    subgraph "Performance Metrics"
        H[Request Duration] --> I[Performance Analysis]
        J[Batch Size] --> K[Throughput Metrics]
    end
    
    style A fill:#e3f2fd
    style C fill:#c8e6c9
    style D fill:#ffcdd2
    style F fill:#c8e6c9
    style G fill:#ffcdd2
```

## Core Metrics

### Input Metrics

```mermaid
graph LR
    A[OTEL Collector] --> B[Logs Received]
    B --> C[Total Count]
    B --> D[Rate per Second]
    
    style B fill:#e3f2fd
    style C fill:#fff3e0
    style D fill:#f3e5f5
```

| Metric | Description | Type | Example |
|--------|-------------|------|---------|
| `logs_received` | Total number of log records received from the OpenTelemetry Collector | Counter | 1,000 logs |
| `logs_received_rate` | Rate of logs received per second | Gauge | 50 logs/sec |

### Processing Metrics

```mermaid
graph TD
    A[Logs Received] --> B{Conversion Success?}
    B -->|Yes| C[Events Exported]
    B -->|No| D[Conversion Errors]
    
    style C fill:#c8e6c9
    style D fill:#ffcdd2
```

| Metric | Description | Type | Example |
|--------|-------------|------|---------|
| `events_exported` | Total number of security events successfully exported | Counter | 950 events |
| `conversion_errors` | Total number of log records that failed to convert to security events | Counter | 50 errors |
| `conversion_success_rate` | Percentage of successful conversions | Gauge | 95% |

### Output Metrics

```mermaid
graph TD
    A[Events Exported] --> B[HTTP Requests]
    B --> C{HTTP Success?}
    C -->|Yes| D[HTTP Success]
    C -->|No| E[HTTP Errors]
    
    style D fill:#c8e6c9
    style E fill:#ffcdd2
```

| Metric | Description | Type | Example |
|--------|-------------|------|---------|
| `http_requests` | Total number of HTTP requests sent to the security event endpoint | Counter | 20 requests |
| `http_errors` | Total number of HTTP requests that failed | Counter | 2 errors |
| `http_success_rate` | Percentage of successful HTTP requests | Gauge | 90% |

### Performance Metrics

```mermaid
graph LR
    A[HTTP Request] --> B[Request Duration]
    B --> C[Average Duration]
    B --> D[P95 Duration]
    B --> E[P99 Duration]
    
    style B fill:#fff3e0
    style C fill:#e3f2fd
    style D fill:#f3e5f5
    style E fill:#ffebee
```

| Metric | Description | Type | Example |
|--------|-------------|------|---------|
| `http_request_duration` | Duration of HTTP requests | Histogram | 150ms average |
| `batch_size` | Number of events per batch | Histogram | 25 events/batch |
| `throughput` | Events processed per second | Gauge | 100 events/sec |

## Metrics Collection Flow

```mermaid
sequenceDiagram
    participant Exporter as Security Event Exporter
    participant Metrics as Metrics Store
    participant Logger as Structured Logger
    participant Monitor as Monitoring System
    
    Exporter->>Metrics: Update logs_received
    Exporter->>Metrics: Update events_exported
    Exporter->>Metrics: Update http_requests
    Exporter->>Metrics: Update http_duration
    
    Metrics->>Logger: Log metrics
    Logger->>Monitor: Send to monitoring system
    
    Monitor->>Monitor: Generate alerts
    Monitor->>Monitor: Update dashboards
```

## Metrics Reporting

### Startup Metrics

```json
{
  "level": "debug",
  "msg": "Initialized telemetry metrics",
  "logs_received": 0,
  "events_exported": 0,
  "events_failed": 0,
  "conversion_errors": 0,
  "http_requests": 0,
  "http_errors": 0
}
```

### Batch Processing Metrics

```json
{
  "level": "info",
  "msg": "Completed processing logs batch",
  "total_resource_logs": 5,
  "total_log_records": 50,
  "successful_events": 48,
  "failed_events": 2,
  "http_requests": 1
}
```

### Shutdown Metrics

```json
{
  "level": "info",
  "msg": "Final telemetry metrics",
  "logs_received": 1000,
  "events_exported": 950,
  "events_failed": 50,
  "conversion_errors": 25,
  "http_requests": 20,
  "http_errors": 5,
  "http_duration_samples": 20
}
```

### Performance Metrics

```json
{
  "level": "info",
  "msg": "HTTP request performance metrics",
  "average_duration": "150ms",
  "sample_count": 20
}
```

## Monitoring and Alerting

### Key Performance Indicators

```mermaid
graph TB
    subgraph "KPIs"
        A[Success Rate] --> B[Events Exported / Total Events]
        C[Error Rate] --> D[Failed Events / Total Events]
        E[Throughput] --> F[Events per Second]
        G[Latency] --> H[Average HTTP Duration]
    end
    
    style B fill:#c8e6c9
    style D fill:#ffcdd2
    style F fill:#e3f2fd
    style H fill:#fff3e0
```

### Alerting Rules

```yaml
# Example alerting rules
alerts:
  - name: HighFailureRate
    condition: events_failed / (events_exported + events_failed) > 0.1
    message: "Security event exporter failure rate is above 10%"
    severity: warning
  
  - name: HighHTTPErrorRate
    condition: http_errors / http_requests > 0.05
    message: "HTTP error rate is above 5%"
    severity: critical
  
  - name: SlowResponseTime
    condition: average_duration > "5s"
    message: "Average HTTP response time is above 5 seconds"
    severity: warning
  
  - name: LowThroughput
    condition: throughput < 10
    message: "Event throughput is below 10 events per second"
    severity: warning
```

### Dashboard Metrics

```mermaid
graph TB
    subgraph "Dashboard Panels"
        A[Success Rate Gauge] --> B[95% Target]
        C[Error Rate Gauge] --> D[<5% Target]
        E[Throughput Graph] --> F[Events/sec over time]
        G[Latency Graph] --> H[Response time over time]
    end
    
    style B fill:#c8e6c9
    style D fill:#ffcdd2
    style F fill:#e3f2fd
    style H fill:#fff3e0
```

## Performance Optimization

### Metrics-Driven Optimization

```mermaid
graph TD
    A[Monitor Metrics] --> B[Identify Bottlenecks]
    B --> C[Analyze Patterns]
    C --> D[Optimize Configuration]
    D --> E[Test Changes]
    E --> F[Deploy Updates]
    F --> A
    
    style B fill:#fff3e0
    style D fill:#e3f2fd
    style F fill:#c8e6c9
```

### Optimization Strategies

1. **Batch Size Optimization**
   - Monitor `batch_size` metrics
   - Adjust collector batch processor settings
   - Balance throughput vs. latency

2. **HTTP Performance Optimization**
   - Monitor `http_request_duration`
   - Optimize endpoint configuration
   - Adjust timeout settings

3. **Error Rate Optimization**
   - Monitor `conversion_errors` and `http_errors`
   - Identify problematic log patterns
   - Adjust error handling logic

## Integration with Monitoring Systems

### Prometheus Integration

```mermaid
graph LR
    A[Structured Logs] --> B[Log Parser]
    B --> C[Metrics Extractor]
    C --> D[Prometheus Metrics]
    D --> E[Grafana Dashboard]
    
    style A fill:#e3f2fd
    style D fill:#fff3e0
    style E fill:#f3e5f5
```

### Log Parsing for Metrics

```bash
# Extract metrics from logs
grep "Final telemetry metrics" collector.logs | \
jq -r '.logs_received, .events_exported, .events_failed' | \
awk '{print "security_event_exporter_logs_received_total " $1; print "security_event_exporter_events_exported_total " $2; print "security_event_exporter_events_failed_total " $3}'
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Security Event Exporter Metrics",
    "panels": [
      {
        "title": "Success Rate",
        "type": "stat",
        "targets": [
          {
            "expr": "security_event_exporter_events_exported_total / (security_event_exporter_events_exported_total + security_event_exporter_events_failed_total) * 100"
          }
        ]
      },
      {
        "title": "Throughput",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(security_event_exporter_events_exported_total[5m])"
          }
        ]
      }
    ]
  }
}
```

## Troubleshooting

### Common Issues and Metrics

```mermaid
graph TD
    A[High Conversion Errors] --> B[Check Log Format]
    C[High HTTP Errors] --> D[Verify Endpoint Config]
    E[Slow Response Times] --> F[Check Network Performance]
    G[Low Throughput] --> H[Optimize Batch Settings]
    
    style B fill:#fff3e0
    style D fill:#fff3e0
    style F fill:#fff3e0
    style H fill:#fff3e0
```

### Debug Mode

Enable debug logging to get detailed metrics information:

```yaml
service:
  telemetry:
    logs:
      level: debug
```

This provides detailed metrics at each processing step, helping identify bottlenecks and issues.

### Performance Analysis

```mermaid
graph LR
    A[Collect Metrics] --> B[Analyze Trends]
    B --> C[Identify Issues]
    C --> D[Apply Fixes]
    D --> E[Monitor Results]
    E --> A
    
    style C fill:#fff3e0
    style D fill:#e3f2fd
    style E fill:#c8e6c9
```

## Future Enhancements

Planned enhancements for metrics collection:

```mermaid
graph TB
    subgraph "Future Features"
        A[Native Prometheus Metrics] --> B[Direct Integration]
        C[Real-time Metrics] --> D[Live Dashboard]
        E[Custom Metrics] --> F[User-defined Metrics]
        G[Metrics Export] --> H[External Processors]
    end
    
    style B fill:#e3f2fd
    style D fill:#fff3e0
    style F fill:#f3e5f5
    style H fill:#c8e6c9
```

1. **Native Prometheus Metrics**: Direct integration with Prometheus metrics
2. **Real-time Metrics**: Live metrics dashboard
3. **Custom Metrics**: User-defined metrics for specific use cases
4. **Metrics Export**: Export metrics to external processors
