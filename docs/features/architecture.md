# Architecture

The Security Event Exporter is designed as a custom component for the OpenTelemetry Collector, providing efficient log-to-security-event transformation and HTTP delivery.

## System Architecture

```mermaid
graph TB
    subgraph "Log Sources"
        A[Applications]
        B[System Logs]
        C[Security Tools]
        D[Network Devices]
    end
    
    subgraph "OpenTelemetry Collector"
        E[Receivers]
        F[Processors]
        G[Security Event Exporter]
    end
    
    subgraph "Security Event Processing"
        H[Log Records]
        I[Event Conversion]
        J[Event Batching]
        K[HTTP Client]
    end
    
    subgraph "External Systems"
        L[SIEM Platform]
        M[Security API]
        N[Event Store]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    
    E --> F
    F --> G
    
    G --> H
    H --> I
    I --> J
    J --> K
    
    K --> L
    K --> M
    K --> N
    
    style G fill:#ff9999
    style H fill:#99ccff
    style I fill:#99ccff
    style J fill:#99ccff
    style K fill:#99ccff
```

## Component Architecture

```mermaid
graph TD
    subgraph "Security Event Exporter"
        A[Config]
        B[Logs Consumer]
        C[Event Converter]
        D[Event Batcher]
        E[HTTP Client]
        F[Telemetry Metrics]
    end
    
    subgraph "External Dependencies"
        G[HTTP Endpoint]
        H[Logger]
        I[Metrics Store]
    end
    
    A --> B
    A --> C
    A --> E
    
    B --> C
    C --> D
    D --> E
    
    B --> F
    C --> F
    D --> F
    E --> F
    
    E --> G
    F --> H
    F --> I
    
    style A fill:#ffeb3b
    style B fill:#4caf50
    style C fill:#2196f3
    style D fill:#ff9800
    style E fill:#f44336
    style F fill:#9c27b0
```

## Data Flow

```mermaid
sequenceDiagram
    participant App as Application
    participant OTLP as OTLP Receiver
    participant Batch as Batch Processor
    participant SecExp as Security Event Exporter
    participant Conv as Event Converter
    participant Batcher as Event Batcher
    participant HTTP as HTTP Client
    participant API as Security API
    
    App->>OTLP: Send Logs
    OTLP->>Batch: Process Logs
    Batch->>SecExp: Consume Logs
    
    SecExp->>Conv: Convert Log to Event
    Conv->>SecExp: Return Security Event
    
    SecExp->>Batcher: Add Event to Batch
    Batcher->>SecExp: Batch Ready
    
    SecExp->>HTTP: Send Event Batch
    HTTP->>API: POST JSON Array
    API->>HTTP: HTTP Response
    HTTP->>SecExp: Success/Error
    
    SecExp->>SecExp: Update Metrics
```

## Event Processing Pipeline

```mermaid
graph LR
    subgraph "Input Processing"
        A[Log Records] --> B[Resource Attributes]
        B --> C[Log Attributes]
        C --> D[Log Body]
    end
    
    subgraph "Event Creation"
        E[Default Attributes] --> F[Event Assembly]
        D --> F
        C --> F
        B --> F
    end
    
    subgraph "Batch Processing"
        F --> G[Event Collection]
        G --> H[Batch Assembly]
        H --> I[JSON Serialization]
    end
    
    subgraph "HTTP Delivery"
        I --> J[HTTP Request]
        J --> K[Response Processing]
        K --> L[Metrics Update]
    end
    
    style A fill:#e1f5fe
    style F fill:#f3e5f5
    style H fill:#fff3e0
    style J fill:#ffebee
```

## Telemetry Metrics Flow

```mermaid
graph TD
    subgraph "Metrics Collection"
        A[Logs Received] --> B[Conversion Success]
        B --> C[Events Exported]
        B --> D[Conversion Errors]
        
        E[HTTP Requests] --> F[HTTP Success]
        E --> G[HTTP Errors]
        
        H[Request Duration] --> I[Performance Metrics]
    end
    
    subgraph "Metrics Reporting"
        C --> J[Structured Logging]
        D --> J
        F --> J
        G --> J
        I --> J
    end
    
    subgraph "Monitoring Systems"
        J --> K[Log Aggregation]
        K --> L[Alerting]
        K --> M[Dashboards]
    end
    
    style A fill:#4caf50
    style C fill:#4caf50
    style D fill:#f44336
    style G fill:#f44336
    style J fill:#2196f3
```

## Configuration Architecture

```mermaid
graph TB
    subgraph "Configuration Sources"
        A[YAML Config File]
        B[Environment Variables]
        C[Command Line Args]
    end
    
    subgraph "Configuration Processing"
        D[Config Parser]
        E[Validation]
        F[Default Values]
    end
    
    subgraph "Runtime Configuration"
        G[Endpoint Settings]
        H[Header Configuration]
        I[Retry Settings]
        J[Queue Settings]
        K[Default Attributes]
    end
    
    A --> D
    B --> D
    C --> D
    
    D --> E
    E --> F
    F --> G
    F --> H
    F --> I
    F --> J
    F --> K
    
    style A fill:#e8f5e8
    style D fill:#fff3cd
    style G fill:#d1ecf1
```

## Error Handling Architecture

```mermaid
graph TD
    subgraph "Error Categories"
        A[Configuration Errors]
        B[Conversion Errors]
        C[HTTP Errors]
        D[Network Errors]
    end
    
    subgraph "Error Handling"
        E[Error Detection]
        F[Error Classification]
        G[Error Logging]
        H[Error Metrics]
        I[Retry Logic]
    end
    
    subgraph "Recovery Actions"
        J[Configuration Validation]
        K[Event Skipping]
        L[HTTP Retry]
        M[Circuit Breaker]
    end
    
    A --> E
    B --> E
    C --> E
    D --> E
    
    E --> F
    F --> G
    F --> H
    F --> I
    
    G --> J
    H --> K
    I --> L
    L --> M
    
    style A fill:#ffcdd2
    style B fill:#ffcdd2
    style C fill:#ffcdd2
    style D fill:#ffcdd2
```

## Performance Characteristics

### Throughput
- **Batch Processing**: Events are batched for efficient HTTP delivery
- **Concurrent Processing**: Multiple log records processed in parallel
- **Memory Management**: Efficient memory usage with streaming processing

### Latency
- **Low Latency**: Direct HTTP delivery without intermediate storage
- **Configurable Timeouts**: Adjustable HTTP timeouts for different environments
- **Retry Logic**: Built-in retry mechanism for transient failures

### Scalability
- **Horizontal Scaling**: Multiple collector instances can be deployed
- **Load Balancing**: HTTP requests can be load balanced across endpoints
- **Resource Efficiency**: Minimal resource footprint with efficient processing

## Security Considerations

### Data Protection
- **Secure Headers**: Support for authentication headers and API tokens
- **TLS Support**: HTTPS endpoint support for encrypted communication
- **Sensitive Data**: Logging excludes sensitive header information

### Network Security
- **Firewall Friendly**: Uses standard HTTP/HTTPS protocols
- **Proxy Support**: Compatible with corporate proxies and firewalls
- **Network Isolation**: Can be deployed in isolated network segments

## Deployment Patterns

### Single Instance
```mermaid
graph LR
    A[Applications] --> B[Single Collector]
    B --> C[Security Event Exporter]
    C --> D[Security API]
```

### High Availability
```mermaid
graph TB
    A[Applications] --> B[Load Balancer]
    B --> C[Collector Instance 1]
    B --> D[Collector Instance 2]
    B --> E[Collector Instance N]
    
    C --> F[Security Event Exporter]
    D --> G[Security Event Exporter]
    E --> H[Security Event Exporter]
    
    F --> I[Security API]
    G --> I
    H --> I
```

### Distributed Deployment
```mermaid
graph TB
    subgraph "Region A"
        A1[Apps] --> B1[Collector]
        B1 --> C1[Security Event Exporter]
    end
    
    subgraph "Region B"
        A2[Apps] --> B2[Collector]
        B2 --> C2[Security Event Exporter]
    end
    
    C1 --> D[Global Security API]
    C2 --> D
```
