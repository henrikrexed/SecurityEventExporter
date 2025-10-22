#!/bin/bash

# Test script for OpenTelemetry Collector with Security Event Exporter

set -e

echo "🧪 Testing OpenTelemetry Collector with Security Event Exporter"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    print_error "docker-compose is not installed. Please install docker-compose and try again."
    exit 1
fi

print_status "Docker and docker-compose are available"

# Build the collector
echo "🔨 Building the collector..."
make docker-build

if [ $? -eq 0 ]; then
    print_status "Collector built successfully"
else
    print_error "Failed to build collector"
    exit 1
fi

# Start the services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Test health check
echo "🏥 Testing health check..."
if curl -f http://localhost:13133/ >/dev/null 2>&1; then
    print_status "Health check passed"
else
    print_warning "Health check failed - collector may still be starting"
fi

# Test OTLP endpoint
echo "📡 Testing OTLP endpoint..."
if curl -f http://localhost:4318/v1/logs >/dev/null 2>&1; then
    print_status "OTLP HTTP endpoint is accessible"
else
    print_warning "OTLP HTTP endpoint test failed"
fi

# Test metrics endpoint
echo "📊 Testing metrics endpoint..."
if curl -f http://localhost:8888/metrics >/dev/null 2>&1; then
    print_status "Metrics endpoint is accessible"
else
    print_warning "Metrics endpoint test failed"
fi

# Test debug endpoint
echo "🐛 Testing debug endpoint..."
if curl -f http://localhost:55679/debug/tracez >/dev/null 2>&1; then
    print_status "Debug endpoint is accessible"
else
    print_warning "Debug endpoint test failed"
fi

# Test pprof endpoint
echo "🔍 Testing pprof endpoint..."
if curl -f http://localhost:1777/debug/pprof/ >/dev/null 2>&1; then
    print_status "pprof endpoint is accessible"
else
    print_warning "pprof endpoint test failed"
fi

# Send test log to collector
echo "📝 Sending test log..."
cat << EOF | curl -X POST http://localhost:4318/v1/logs \
  -H "Content-Type: application/json" \
  -d @- >/dev/null 2>&1
{
  "resourceLogs": [{
    "resource": {
      "attributes": [{
        "key": "service.name",
        "value": {"stringValue": "test-service"}
      }]
    },
    "scopeLogs": [{
      "scope": {
        "name": "test-scope"
      },
      "logRecords": [{
        "timeUnixNano": "$(date +%s)000000000",
        "severityText": "INFO",
        "body": {"stringValue": "Test security event"},
        "attributes": [{
          "key": "security.event.type",
          "value": {"stringValue": "authentication"}
        }]
      }]
    }]
  }]
}
EOF

if [ $? -eq 0 ]; then
    print_status "Test log sent successfully"
else
    print_warning "Failed to send test log"
fi

# Check collector logs
echo "📋 Checking collector logs..."
docker-compose logs otelcol-security --tail=20

echo ""
echo "🎉 Test completed!"
echo ""
echo "📊 Available endpoints:"
echo "  - Health Check: http://localhost:13133/"
echo "  - Metrics: http://localhost:8888/metrics"
echo "  - Debug: http://localhost:55679/debug/tracez"
echo "  - pprof: http://localhost:1777/debug/pprof/"
echo "  - OTLP HTTP: http://localhost:4318/v1/logs"
echo "  - OTLP gRPC: localhost:4317"
echo ""
echo "🔧 To stop services: docker-compose down"
echo "📝 To view logs: docker-compose logs -f otelcol-security"
