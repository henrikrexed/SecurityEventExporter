# Deployment Guide

## Overview

This guide covers various deployment scenarios for the OpenTelemetry Security Event Exporter, including Docker, Kubernetes, and cloud platforms.

## Prerequisites

- Docker or Podman
- Kubernetes cluster (for K8s deployment)
- Access to the security event endpoint
- Proper network connectivity

## Docker Deployment

### Basic Docker Run

```bash
docker run -d \
  --name otel-security-collector \
  -p 4317:4317 \
  -p 4318:4318 \
  -p 8888:8888 \
  -p 8889:8889 \
  -p 13133:13133 \
  -v $(pwd)/collector-config.yaml:/otel/collector-config.yaml \
  hrexed/otel-collector-sec-event:dev
```

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  otel-collector:
    image: hrexed/otel-collector-sec-event:dev
    container_name: otel-security-collector
    ports:
      - "4317:4317"   # OTLP gRPC receiver
      - "4318:4318"   # OTLP HTTP receiver
      - "8888:8888"   # Prometheus metrics
      - "8889:8889"   # Prometheus exporter metrics
      - "13133:13133" # Health check
    volumes:
      - ./collector-config.yaml:/otel/collector-config.yaml:ro
      - ./logs:/var/log/otel:ro
    environment:
      - OTEL_LOG_LEVEL=info
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "wget", "--no-verbose", "--tries=1", "--spider", "http://localhost:13133/"]
      interval: 30s
      timeout: 30s
      retries: 3
      start_period: 5s

  # Example application sending logs
  test-app:
    image: nginx:alpine
    container_name: test-app
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./logs:/var/log/nginx:ro
    depends_on:
      - otel-collector
```

### Environment Variables

Configure the collector using environment variables:

```bash
docker run -d \
  --name otel-security-collector \
  -e OTEL_LOG_LEVEL=debug \
  -e SECURITY_ENDPOINT=https://your-endpoint.com/events \
  -e API_TOKEN=your-token \
  hrexed/otel-collector-sec-event:dev
```

## Kubernetes Deployment

### Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: otel-security
```

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-config
  namespace: otel-security
data:
  collector-config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
      filelog:
        include: ["/var/log/containers/*.log"]
        operators:
          - type: json_parser
            parse_from: body
            parse_to: body
      k8sobjects:
        objects:
          - name: events
            mode: watch
            group: ""
            version: v1
            resource: events
            namespaces: ["default", "kube-system"]

    processors:
      memory_limiter:
        limit_mib: 512
      batch:
        timeout: 1s
        send_batch_size: 1024
      resource:
        attributes:
          - key: k8s.cluster.name
            value: production
            action: insert
      filter:
        logs:
          exclude:
            match_type: regexp
            record_attributes:
              - key: message
                value: "^(GET|POST|PUT|DELETE) /health"

    exporters:
      otlp:
        endpoint: "https://your-otel-backend.com:4317"
        tls:
          insecure: false
      debug:
        verbosity: basic
      securityevent:
        endpoint: "https://your-security-endpoint.com/events"
        timeout: 30s
        headers:
          Authorization: "Bearer ${API_TOKEN}"
          Content-Type: "application/json"
        default_attributes:
          source: "kubernetes-cluster"
          environment: "production"
        retry_on_failure:
          enabled: true
          initial_interval: 5s
          max_interval: 30s
          max_elapsed_time: 5m
        sending_queue:
          enabled: true
          num_consumers: 10
          queue_size: 1000

    service:
      pipelines:
        logs:
          receivers: [otlp, filelog, k8sobjects]
          processors: [memory_limiter, batch, resource, filter]
          exporters: [otlp, debug, securityevent]
      telemetry:
        logs:
          level: info
        metrics:
          address: 0.0.0.0:8888
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: otel-secrets
  namespace: otel-security
type: Opaque
data:
  api-token: <base64-encoded-token>
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-security-collector
  namespace: otel-security
  labels:
    app: otel-security-collector
spec:
  replicas: 2
  selector:
    matchLabels:
      app: otel-security-collector
  template:
    metadata:
      labels:
        app: otel-security-collector
    spec:
      serviceAccountName: otel-collector
      containers:
      - name: otel-collector
        image: hrexed/otel-collector-sec-event:dev
        ports:
        - containerPort: 4317
          name: otlp-grpc
          protocol: TCP
        - containerPort: 4318
          name: otlp-http
          protocol: TCP
        - containerPort: 8888
          name: metrics
          protocol: TCP
        - containerPort: 8889
          name: exporter-metrics
          protocol: TCP
        - containerPort: 13133
          name: health-check
          protocol: TCP
        env:
        - name: API_TOKEN
          valueFrom:
            secretKeyRef:
              name: otel-secrets
              key: api-token
        - name: OTEL_LOG_LEVEL
          value: "info"
        volumeMounts:
        - name: config
          mountPath: /otel/collector-config.yaml
          subPath: collector-config.yaml
        - name: logs
          mountPath: /var/log/containers
          readOnly: true
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /
            port: 13133
          initialDelaySeconds: 30
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /
            port: 13133
          initialDelaySeconds: 5
          periodSeconds: 10
      volumes:
      - name: config
        configMap:
          name: otel-config
      - name: logs
        hostPath:
          path: /var/log/containers
```

### Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: otel-security-collector
  namespace: otel-security
  labels:
    app: otel-security-collector
spec:
  type: ClusterIP
  ports:
  - name: otlp-grpc
    port: 4317
    targetPort: 4317
    protocol: TCP
  - name: otlp-http
    port: 4318
    targetPort: 4318
    protocol: TCP
  - name: metrics
    port: 8888
    targetPort: 8888
    protocol: TCP
  - name: exporter-metrics
    port: 8889
    targetPort: 8889
    protocol: TCP
  - name: health-check
    port: 13133
    targetPort: 13133
    protocol: TCP
  selector:
    app: otel-security-collector
```

### ServiceAccount and RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: otel-collector
  namespace: otel-security

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: otel-collector
rules:
- apiGroups: [""]
  resources: ["events"]
  verbs: ["get", "list", "watch"]
- apiGroups: [""]
  resources: ["pods", "nodes", "services"]
  verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: otel-collector
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: otel-collector
subjects:
- kind: ServiceAccount
  name: otel-collector
  namespace: otel-security
```

### DaemonSet (for node-level collection)

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: otel-security-collector-daemonset
  namespace: otel-security
  labels:
    app: otel-security-collector
spec:
  selector:
    matchLabels:
      app: otel-security-collector
  template:
    metadata:
      labels:
        app: otel-security-collector
    spec:
      serviceAccountName: otel-collector
      hostNetwork: true
      containers:
      - name: otel-collector
        image: hrexed/otel-collector-sec-event:dev
        ports:
        - containerPort: 4317
          name: otlp-grpc
          protocol: TCP
        - containerPort: 4318
          name: otlp-http
          protocol: TCP
        - containerPort: 8888
          name: metrics
          protocol: TCP
        - containerPort: 13133
          name: health-check
          protocol: TCP
        env:
        - name: API_TOKEN
          valueFrom:
            secretKeyRef:
              name: otel-secrets
              key: api-token
        - name: OTEL_LOG_LEVEL
          value: "info"
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        volumeMounts:
        - name: config
          mountPath: /otel/collector-config.yaml
          subPath: collector-config.yaml
        - name: varlog
          mountPath: /var/log
          readOnly: true
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        securityContext:
          runAsUser: 0
      volumes:
      - name: config
        configMap:
          name: otel-config
      - name: varlog
        hostPath:
          path: /var/log
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
```

## Helm Chart

### Chart Structure

```
helm-chart/
├── Chart.yaml
├── values.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── serviceaccount.yaml
│   ├── rbac.yaml
│   └── daemonset.yaml
└── README.md
```

### Chart.yaml

```yaml
apiVersion: v2
name: otel-security-collector
description: OpenTelemetry Collector with Security Event Exporter
version: 1.0.0
appVersion: "1.0.0"
keywords:
  - opentelemetry
  - collector
  - security
  - logging
home: https://github.com/your-org/SecurityEventExporter
sources:
  - https://github.com/your-org/SecurityEventExporter
maintainers:
  - name: Your Name
    email: your.email@example.com
```

### values.yaml

```yaml
image:
  repository: hrexed/otel-collector-sec-event
  tag: dev
  pullPolicy: IfNotPresent

replicaCount: 2

service:
  type: ClusterIP
  ports:
    otlp-grpc: 4317
    otlp-http: 4318
    metrics: 8888
    exporter-metrics: 8889
    health-check: 13133

securityEvent:
  endpoint: "https://your-security-endpoint.com/events"
  timeout: 30s
  headers: {}
  defaultAttributes:
    source: "kubernetes-cluster"
    environment: "production"
  retryOnFailure:
    enabled: true
    initialInterval: 5s
    maxInterval: 30s
    maxElapsedTime: 5m
  sendingQueue:
    enabled: true
    numConsumers: 10
    queueSize: 1000

resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"

nodeSelector: {}

tolerations: []

affinity: {}

serviceAccount:
  create: true
  annotations: {}
  name: ""

rbac:
  create: true

podAnnotations: {}

podSecurityContext:
  fsGroup: 2000

securityContext:
  capabilities:
    drop:
    - ALL
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000

livenessProbe:
  httpGet:
    path: /
    port: 13133
  initialDelaySeconds: 30
  periodSeconds: 30

readinessProbe:
  httpGet:
    path: /
    port: 13133
  initialDelaySeconds: 5
  periodSeconds: 10
```

## Cloud Platform Deployment

### AWS EKS

```bash
# Create EKS cluster
eksctl create cluster --name otel-security --region us-west-2

# Deploy using Helm
helm install otel-security ./helm-chart \
  --set securityEvent.endpoint="https://your-aws-endpoint.com/events" \
  --set securityEvent.headers.Authorization="Bearer ${AWS_TOKEN}"
```

### Google GKE

```bash
# Create GKE cluster
gcloud container clusters create otel-security \
  --zone us-central1-a \
  --num-nodes 3

# Deploy using Helm
helm install otel-security ./helm-chart \
  --set securityEvent.endpoint="https://your-gcp-endpoint.com/events" \
  --set securityEvent.headers.Authorization="Bearer ${GCP_TOKEN}"
```

### Azure AKS

```bash
# Create AKS cluster
az aks create \
  --resource-group myResourceGroup \
  --name otel-security \
  --node-count 3 \
  --enable-addons monitoring

# Deploy using Helm
helm install otel-security ./helm-chart \
  --set securityEvent.endpoint="https://your-azure-endpoint.com/events" \
  --set securityEvent.headers.Authorization="Bearer ${AZURE_TOKEN}"
```

## Monitoring and Observability

### Prometheus Metrics

The collector exposes metrics at `http://localhost:8888/metrics`:

```yaml
# Prometheus scrape config
scrape_configs:
  - job_name: 'otel-collector'
    static_configs:
      - targets: ['otel-collector:8888']
    scrape_interval: 15s
```

### Grafana Dashboard

Create a Grafana dashboard to monitor:

- Collector health
- Processing rates
- Error rates
- Queue sizes
- Memory usage

### Alerting Rules

```yaml
groups:
  - name: otel-collector
    rules:
      - alert: OtelCollectorDown
        expr: up{job="otel-collector"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "OpenTelemetry Collector is down"
      
      - alert: OtelCollectorHighErrorRate
        expr: rate(otelcol_exporter_send_failed_logs_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate in OpenTelemetry Collector"
```

## Troubleshooting

### Common Issues

1. **Collector not starting**: Check configuration syntax and required fields
2. **Connection refused**: Verify endpoint URL and network connectivity
3. **Authentication failed**: Check API tokens and headers
4. **High memory usage**: Adjust queue size and number of consumers
5. **Slow performance**: Check network latency and endpoint response times

### Debug Commands

```bash
# Check collector logs
kubectl logs -f deployment/otel-security-collector -n otel-security

# Check collector health
curl http://localhost:13133/

# Check metrics
curl http://localhost:8888/metrics

# Test configuration
docker run --rm -v $(pwd)/collector-config.yaml:/config.yaml \
  hrexed/otel-collector-sec-event:dev --config /config.yaml --dry-run
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

### Security Considerations

1. **Use TLS**: Always use HTTPS for the security event endpoint
2. **API Tokens**: Store API tokens in Kubernetes secrets
3. **Network Policies**: Implement network policies to restrict traffic
4. **RBAC**: Use proper RBAC for Kubernetes resources
5. **Image Security**: Use trusted base images and scan for vulnerabilities
