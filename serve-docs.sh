#!/bin/bash

# Security Event Exporter Documentation Server
# This script serves the MkDocs documentation site locally

echo "🚀 Starting Security Event Exporter Documentation Server"
echo "=================================================="

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Check if pip is installed
if ! command -v pip3 &> /dev/null; then
    echo "❌ pip3 is required but not installed."
    exit 1
fi

# Install requirements if not already installed
echo "📦 Installing MkDocs dependencies..."
pip3 install -r requirements.txt

# Check if MkDocs is working
if ! command -v mkdocs &> /dev/null; then
    echo "❌ MkDocs installation failed."
    exit 1
fi

echo "✅ Dependencies installed successfully"
echo ""

# Serve the documentation
echo "🌐 Starting documentation server..."
echo "📖 Documentation will be available at: http://localhost:8000"
echo "🔄 Press Ctrl+C to stop the server"
echo ""

mkdocs serve --dev-addr=0.0.0.0:8000
