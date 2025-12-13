# OpenTelemetry Security Event Exporter v0.1.1

## 🎉 Patch Release

This patch release includes important improvements to the JSON output format and conflict detection.

## ✨ Changes

### JSON Output Format
- **Flattened Properties**: All properties are now at the root level of the JSON object
  - Removed `attributes.` prefix from log attributes
  - Removed `resource.` prefix from resource attributes
  - All properties are now directly accessible at the root level

### Conflict Detection
- **Attribute Conflict Detection**: Added detection and warning for conflicts between resource and log attributes
  - Warning logs when a log attribute key conflicts with a resource attribute key
  - Log attribute values will overwrite resource attribute values (with warning)
  - New metric: `attribute_conflicts` counter tracks the number of conflicts detected

### Metrics Enhancement
- Added `attribute_conflicts` counter to track attribute key conflicts
- Included in telemetry metrics reporting

## 🔧 Example Output

### Before (v0.1.0)
```json
{
  "attributes.compliance.control": "check-sysctls",
  "resource.k8s.cluster.name": "obs-security-event",
  "message": "validation rule passed",
  "timestamp": "2025-12-12T14:01:24Z"
}
```

### After (v0.1.1)
```json
{
  "compliance.control": "check-sysctls",
  "k8s.cluster.name": "obs-security-event",
  "message": "validation rule passed",
  "timestamp": "2025-12-12T14:01:24Z"
}
```

## 📋 Breaking Changes

⚠️ **Breaking Change**: The JSON output format has changed. Properties that were previously prefixed with `attributes.` or `resource.` are now at the root level without prefixes.

If you have downstream systems that depend on the prefixed format, you will need to update them.

## 🐛 Bug Fixes

- Fixed JSON structure to have all properties at root level as expected by security event consumers

## 📦 Installation

### As a Go Module Dependency

```bash
go get github.com/henrikrexed/SecurityEventExporter@v0.1.1
```

Or add directly to your `go.mod`:
```go
require github.com/henrikrexed/SecurityEventExporter v0.1.1
```

### Using in OCB Manifest

```yaml
exporters:
  - gomod: github.com/henrikrexed/SecurityEventExporter v0.1.1
```

### Docker Image

```bash
docker pull ghcr.io/henrikrexed/securityeventexporter:v0.1.1
```

## 📝 Changelog

### v0.1.1
- ✅ Flattened JSON output - all properties at root level
- ✅ Added attribute conflict detection and warnings
- ✅ Added `attribute_conflicts` counter metric
- ✅ Improved logging for conflict scenarios

## 🔗 Links

- **GitHub Repository**: [https://github.com/henrikrexed/SecurityEventExporter](https://github.com/henrikrexed/SecurityEventExporter)
- **Docker Hub**: `ghcr.io/henrikrexed/securityeventexporter`
- **Issues**: [https://github.com/henrikrexed/SecurityEventExporter/issues](https://github.com/henrikrexed/SecurityEventExporter/issues)
