# Quick Start

Get up and running with the Security Event Exporter in minutes!

## Prerequisites

- Docker or Podman
- Basic understanding of OpenTelemetry concepts

## 🚀 Quick Start with Docker

### 1. Run the Collector

```bash
docker run -d \
  --name otel-security-exporter \
  -p 4317:4317 \
  -p 8888:8888 \
  -p 13133:13133 \
  hrexed/otel-collector-sec-event:latest
```

### 2. Verify the Collector is Running

```bash
# Check collector health
curl http://localhost:13133/

# Check metrics endpoint
curl http://localhost:8888/metrics
```

### 3. Send Test Logs

```bash
curl -X POST http://localhost:4317/v1/logs \
  -H "Content-Type: application/json" \
  -d '{
    "resourceLogs": [{
      "resource": {
        "attributes": [{
          "key": "service.name",
          "value": {"stringValue": "my-security-service"}
        }]
      },
      "scopeLogs": [{
        "logRecords": [{
          "body": {"stringValue": "Security event detected: unauthorized access attempt"},
          "severityText": "ERROR",
          "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
        }]
      }]
    }]
  }'
```

## 📋 Configuration

The collector comes with a default configuration that includes the Security Event Exporter. Here's a minimal configuration:

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318

processors:
  batch:

exporters:
  securityevent:
    endpoint: https://your-security-endpoint.com/events
    headers:
      authorization: "Bearer your-api-token"
    default_attributes:
      source: "otel-collector"
      environment: "production"

service:
  pipelines:
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [securityevent]
```

## 🔧 Custom Configuration

### Using a Custom Config File

```bash
docker run -d \
  --name otel-security-exporter \
  -p 4317:4317 \
  -p 8888:8888 \
  -v $(pwd)/my-config.yaml:/otel/config.yaml \
  hrexed/otel-collector-sec-event:latest \
  --config /otel/config.yaml
```

### Environment Variables

```bash
docker run -d \
  --name otel-security-exporter \
  -p 4317:4317 \
  -p 8888:8888 \
  -e OTEL_SECURITY_ENDPOINT="https://your-endpoint.com/events" \
  -e OTEL_SECURITY_API_TOKEN="your-token" \
  hrexed/otel-collector-sec-event:latest
```

## 📊 Monitoring

### View Logs

```bash
# View collector logs
docker logs otel-security-exporter

# Follow logs in real-time
docker logs -f otel-security-exporter
```

### Check Metrics

```bash
# View telemetry metrics
curl http://localhost:8888/metrics | grep security_event
```

## 🧪 Testing

### Test with Sample Data

```bash
# Create a test script
cat > test-logs.sh << 'EOF'
#!/bin/bash

for i in {1..10}; do
  curl -X POST http://localhost:4317/v1/logs \
    -H "Content-Type: application/json" \
    -d "{
      \"resourceLogs\": [{
        \"resource\": {
          \"attributes\": [{
            \"key\": \"service.name\",
            \"value\": {\"stringValue\": \"test-service-$i\"}
          }]
        },
        \"scopeLogs\": [{
          \"logRecords\": [{
            \"body\": {\"stringValue\": \"Test security event $i\"},
            \"severityText\": \"INFO\",
            \"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"
          }]
        }]
      }]
    }"
  echo "Sent test log $i"
  sleep 1
done
EOF

chmod +x test-logs.sh
./test-logs.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Collector won't start**: Check port availability
2. **No logs being processed**: Verify endpoint configuration
3. **HTTP errors**: Check network connectivity and API tokens

### Debug Mode

Enable debug logging:

```bash
docker run -d \
  --name otel-security-exporter \
  -p 4317:4317 \
  -p 8888:8888 \
  hrexed/otel-collector-sec-event:latest \
  --set service.telemetry.logs.level=debug
```

## 📚 Next Steps

- **[Configuration Guide](configuration.md)** - Detailed configuration options
- **[Telemetry Metrics](monitoring/telemetry-metrics.md)** - Monitoring and metrics
- **[Deployment Guide](deployment/docker-deployment.md)** - Production deployment
- **[API Reference](development/api-reference.md)** - Complete API documentation

## 🆘 Need Help?

- Check the [Troubleshooting Guide](../troubleshooting/common-issues.md)
- Join our [GitHub Discussions](https://github.com/opentelemetry/securityeventexporter/discussions)
- Report issues on [GitHub](https://github.com/opentelemetry/securityeventexporter/issues)
