# Telemetry Metrics Guide

The Security Event Exporter provides comprehensive telemetry metrics to monitor its performance and operational status. These metrics help you understand the exporter's behavior, identify potential issues, and optimize performance.

## Metrics Overview

The exporter tracks the following key metrics:

### Core Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `logs_received` | Total number of log records received from the OpenTelemetry Collector | Counter |
| `events_exported` | Total number of security events successfully exported | Counter |
| `events_failed` | Total number of security events that failed to be exported | Counter |
| `conversion_errors` | Total number of log records that failed to convert to security events | Counter |

### HTTP Communication Metrics

| Metric | Description | Type |
|--------|-------------|------|
| `http_requests` | Total number of HTTP requests sent to the security event endpoint | Counter |
| `http_errors` | Total number of HTTP requests that failed | Counter |
| `http_durations` | Array of HTTP request durations for performance analysis | Histogram |

## Metrics Collection

### Log-Based Metrics

All metrics are currently reported through structured logging. The exporter logs metrics at key lifecycle events:

#### Startup Metrics
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

#### Batch Processing Metrics
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

#### Shutdown Metrics
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

#### Performance Metrics
```json
{
  "level": "info",
  "msg": "HTTP request performance metrics",
  "average_duration": "150ms",
  "sample_count": 20
}
```

## Batching Behavior

The exporter implements intelligent batching to optimize HTTP requests:

- **Batch Collection**: All log records from a single batch are collected and converted to security events
- **Single HTTP Request**: All security events in a batch are sent in a single HTTP POST request as a JSON array
- **Efficient Processing**: This reduces the number of HTTP requests and improves overall throughput

### Batch Metrics Example

```json
{
  "level": "debug",
  "msg": "Sending batch of security events",
  "event_count": 25,
  "endpoint": "https://api.example.com/security-events"
}
```

## Monitoring and Alerting

### Key Metrics to Monitor

1. **Success Rate**: `events_exported / (events_exported + events_failed)`
2. **Conversion Rate**: `events_exported / logs_received`
3. **HTTP Error Rate**: `http_errors / http_requests`
4. **Average Response Time**: Average of `http_durations`

### Recommended Alerts

```yaml
# Example alerting rules
alerts:
  - name: HighFailureRate
    condition: events_failed / (events_exported + events_failed) > 0.1
    message: "Security event exporter failure rate is above 10%"
  
  - name: HighHTTPErrorRate
    condition: http_errors / http_requests > 0.05
    message: "HTTP error rate is above 5%"
  
  - name: SlowResponseTime
    condition: average_duration > "5s"
    message: "Average HTTP response time is above 5 seconds"
```

## Performance Optimization

### Metrics-Driven Optimization

Use the collected metrics to optimize exporter performance:

1. **Batch Size Analysis**: Monitor `events_exported` per `http_requests` to understand batching efficiency
2. **Error Pattern Analysis**: Analyze `conversion_errors` and `http_errors` to identify problematic log patterns
3. **Response Time Analysis**: Use `http_durations` to identify performance bottlenecks

### Configuration Tuning

Based on metrics analysis, you can tune:

- **Timeout Settings**: Adjust HTTP timeout based on response time patterns
- **Retry Settings**: Configure retry behavior based on error rates
- **Batch Processing**: Optimize batch sizes based on throughput requirements

## Integration with Monitoring Systems

### Prometheus Integration

While the current implementation uses logging, you can integrate with Prometheus by:

1. Parsing the structured logs
2. Extracting metrics from log entries
3. Converting to Prometheus metrics format

### Example Log Parser

```bash
# Extract metrics from logs
grep "Final telemetry metrics" collector.logs | \
jq -r '.logs_received, .events_exported, .events_failed' | \
awk '{print "security_event_exporter_logs_received_total " $1; print "security_event_exporter_events_exported_total " $2; print "security_event_exporter_events_failed_total " $3}'
```

## Troubleshooting

### Common Issues and Metrics

1. **High Conversion Errors**: Check log format compatibility
2. **High HTTP Errors**: Verify endpoint configuration and network connectivity
3. **Slow Response Times**: Analyze endpoint performance and network conditions
4. **Low Success Rate**: Investigate both conversion and HTTP errors

### Debug Mode

Enable debug logging to get detailed metrics information:

```yaml
service:
  telemetry:
    logs:
      level: debug
```

This provides detailed metrics at each processing step, helping identify bottlenecks and issues.

## Future Enhancements

Planned enhancements for metrics collection:

1. **Native Prometheus Metrics**: Direct integration with Prometheus metrics
2. **Real-time Metrics**: Live metrics dashboard
3. **Custom Metrics**: User-defined metrics for specific use cases
4. **Metrics Export**: Export metrics to external processors
