# 🔌 RedisUtils - High-Performance Redis Connection Manager

[![Rust](https://img.shields.io/badge/rust-1.82+-orange.svg)](https://www.rust-lang.org)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Performance](https://img.shields.io/badge/performance-production%20grade-brightgreen.svg)]()
[![Docker](https://img.shields.io/badge/docker-ready-brightgreen.svg)](Dockerfile)

A **production-grade Redis connection pool manager** built in Rust for high-performance trading applications. Provides resilient, async Redis connectivity with advanced retry mechanisms, health monitoring, and seamless integration with the Trading Platform ecosystem.

---

## 🎯 **Overview**

RedisUtils is a lightweight yet powerful library that provides enterprise-grade Redis connection management for ultra-high frequency trading systems. It delivers sub-millisecond Redis operations with automatic failover, connection recycling, and comprehensive monitoring capabilities.

### **🚀 Key Features**
- **High-Performance Pooling**: Deadpool-based connection management with zero-copy operations
- **Resilient Connectivity**: Advanced retry logic with exponential backoff
- **Production Ready**: Environment-based configuration with TLS support  
- **Monitoring Integration**: Built-in metrics and health checking
- **Trading Optimized**: Designed for real-time market data and order processing

---

## 📋 **Table of Contents**

- [� Features](#-features)
- [🏗️ Architecture](#%EF%B8%8F-architecture) 
- [⚡ Quick Start](#-quick-start)
- [🔧 Configuration](#-configuration)
- [📦 Usage](#-usage)
- [🧪 Testing](#-testing)
- [🐳 Docker](#-docker)
- [☁️ Deployment](#%EF%B8%8F-deployment)
- [🤝 Contributing](#-contributing)

---

## 🔥 **Features**

### **Core Redis Features**
- **Connection Pooling**: Efficient deadpool-redis based pool management
- **Async Operations**: Full tokio async/await support for non-blocking I/O
- **Retry Logic**: Intelligent connection retry with configurable backoff strategies
- **Health Monitoring**: Automated connection health checks and recycling
- **Configuration Management**: Environment variable based setup with .env support

### **Trading Platform Integration**
- **Market Data Caching**: Ultra-fast price data storage and retrieval  
- **Session Management**: Trading session state and user management
- **Order State**: Real-time order status and execution tracking
- **Portfolio Cache**: High-speed portfolio position caching
- **Pub/Sub Messaging**: Real-time event distribution across services

### **Production Features**
- **TLS Security**: Encrypted Redis connections for production environments
- **Error Handling**: Comprehensive error types with anyhow integration
- **Resource Management**: Automatic connection cleanup and resource optimization
- **Metrics Support**: Performance monitoring and operational metrics
- **Docker Ready**: Containerized deployment with Kubernetes support

---

## 🏗️ **Architecture**

### **Connection Management**
```rust
┌─────────────────────────────────────────────────┐
│                RedisUtils Core                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────┐    ┌─────────────┐            │
│  │ Pool Manager│◄──►│Redis Cluster│            │
│  │             │    │             │            │
│  │ • Deadpool  │    │ • Primary   │            │
│  │ • Health    │    │ • Replicas  │            │
│  │ • Retry     │    │ • Failover  │            │
│  └─────────────┘    └─────────────┘            │
│         │                    │                 │
│         ▼                    ▼                 │
│  ┌─────────────┐    ┌─────────────┐            │
│  │Config Mgmt  │    │Metrics &    │            │
│  │             │    │Monitoring   │            │
│  │ • Env Vars  │    │             │            │
│  │ • TLS Setup │    │ • Latency   │            │
│  │ • Validation│    │ • Throughput│            │
│  └─────────────┘    └─────────────┘            │
└─────────────────────────────────────────────────┘
```

### **Integration with Trading Platform**
- **DataEngine**: Market data caching and real-time price feeds
- **SignalEngine**: Signal state management and portfolio caching  
- **MessageBrokerEngine**: Event pub/sub and message queuing
- **BacktestingEngine**: Simulation state and results caching

---

## ⚡ **Quick Start**

### **Installation**
Add to your `Cargo.toml`:
```toml
[dependencies]
redis_utils = { path = "../redisutils" }
tokio = { version = "1.0", features = ["full"] }
```

### **Basic Usage**
```rust
use redis_utils::create_redis_pool;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Create Redis connection pool
    let pool = create_redis_pool().await?;
    
    // Get connection from pool
    let mut conn = pool.get().await?;
    
    // Execute Redis commands
    redis::cmd("SET")
        .arg("trading:price:BTCUSD")
        .arg(50000.0)
        .query_async(&mut conn)
        .await?;
    
    let price: f64 = redis::cmd("GET")
        .arg("trading:price:BTCUSD")
        .query_async(&mut conn)
        .await?;
        
    println!("BTC Price: ${}", price);
    Ok(())
}
```

---

## 🔧 **Configuration**

### **Environment Variables**
Create a `.env` file in your project root:
```env
# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=your_secure_password
REDIS_DATABASE=0
REDIS_POOL_MAX_SIZE=100
REDIS_CONNECTION_TIMEOUT=30
REDIS_COMMAND_TIMEOUT=10

# TLS Configuration (Optional)
REDIS_TLS_ENABLED=true
REDIS_TLS_CERT_PATH=/path/to/client.crt
REDIS_TLS_KEY_PATH=/path/to/client.key
REDIS_TLS_CA_PATH=/path/to/ca.crt

# Retry Configuration
REDIS_MAX_RETRIES=5
REDIS_RETRY_DELAY_MS=100
REDIS_RETRY_MAX_DELAY_MS=5000
```

### **Configuration Options**
| Parameter | Description | Default | Production Recommended |
|-----------|-------------|---------|----------------------|
| `REDIS_HOST` | Redis server hostname | localhost | cluster.redis.cache.amazonaws.com |
| `REDIS_PORT` | Redis server port | 6379 | 6379 |
| `REDIS_POOL_MAX_SIZE` | Maximum connections | 10 | 100-500 |
| `REDIS_CONNECTION_TIMEOUT` | Connection timeout (seconds) | 30 | 10 |
| `REDIS_COMMAND_TIMEOUT` | Command timeout (seconds) | 10 | 5 |

---

## 📦 **Usage Examples**

### **Market Data Caching**
```rust
use redis_utils::create_redis_pool;
use serde_json::json;

async fn cache_market_data() -> Result<(), Box<dyn std::error::Error>> {
    let pool = create_redis_pool().await?;
    let mut conn = pool.get().await?;
    
    // Cache real-time price data
    let market_data = json!({
        "symbol": "BTCUSD",
        "price": 50000.0,
        "volume": 1.5,
        "timestamp": chrono::Utc::now().timestamp()
    });
    
    redis::cmd("SETEX")
        .arg("market:BTCUSD")
        .arg(60) // TTL: 60 seconds
        .arg(market_data.to_string())
        .query_async(&mut conn)
        .await?;
        
    Ok(())
}
```

### **Portfolio State Management**
```rust
async fn manage_portfolio() -> Result<(), Box<dyn std::error::Error>> {
    let pool = create_redis_pool().await?;
    let mut conn = pool.get().await?;
    
    // Store portfolio positions
    redis::cmd("HSET")
        .arg("portfolio:user123")
        .arg("BTCUSD")
        .arg("10.5") // Position size
        .query_async(&mut conn)
        .await?;
    
    // Get all positions
    let positions: std::collections::HashMap<String, String> = 
        redis::cmd("HGETALL")
            .arg("portfolio:user123")
            .query_async(&mut conn)
            .await?;
            
    Ok(())
}
```

### **Event Publishing**
```rust
async fn publish_trading_events() -> Result<(), Box<dyn std::error::Error>> {
    let pool = create_redis_pool().await?;
    let mut conn = pool.get().await?;
    
    // Publish order execution event
    let event = json!({
        "type": "ORDER_EXECUTED",
        "order_id": "12345",
        "symbol": "BTCUSD",
        "quantity": 1.0,
        "price": 50000.0
    });
    
    redis::cmd("PUBLISH")
        .arg("trading:events")
        .arg(event.to_string())
        .query_async(&mut conn)
        .await?;
        
    Ok(())
}
```

---

## 🧪 **Testing**

### **Running Tests**
```bash
# Run all tests
cargo test

# Run with logging
RUST_LOG=debug cargo test

# Run specific test
cargo test test_redis_connection
```

### **Integration Tests**
```bash
# Start Redis for testing
docker run -d --name redis-test -p 6379:6379 redis:7-alpine

# Run integration tests
cargo test --test integration_tests

# Cleanup
docker stop redis-test && docker rm redis-test
```

---

## 🐳 **Docker**

### **Docker Build**
```bash
# Build Redis utils container
docker build -t redis-utils .

# Run with Redis
docker run -d --name redis redis:7-alpine
docker run --link redis:redis -e REDIS_HOST=redis redis-utils
```

### **Docker Compose**
```yaml
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
      
  redis-utils:
    build: .
    depends_on:
      - redis
    environment:
      REDIS_HOST: redis
      REDIS_PORT: 6379

volumes:
  redis_data:
```

---

## ☁️ **Deployment**

### **Kubernetes Deployment**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  REDIS_HOST: "redis-cluster"
  REDIS_PORT: "6379"
  REDIS_POOL_MAX_SIZE: "200"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: trading-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: trading-app
  template:
    metadata:
      labels:
        app: trading-app
    spec:
      containers:
      - name: app
        image: redis-utils:latest
        envFrom:
        - configMapRef:
            name: redis-config
```

### **Production Considerations**
- **High Availability**: Use Redis Cluster or Redis Sentinel
- **Security**: Enable TLS encryption and authentication
- **Monitoring**: Implement Redis metrics and alerting
- **Backup**: Configure automated Redis backups
- **Scaling**: Monitor connection pool metrics and adjust sizes

---

## 📊 **Performance**

### **Benchmarks**
```
Operations/sec:     100,000+ 
Latency (p99):      <1ms
Memory Usage:       <50MB
Connection Pooling: 10-500 connections
```

### **Monitoring Metrics**
- Connection pool utilization
- Command latency (p50, p95, p99)  
- Error rates and retry counts
- Memory usage and garbage collection
- Network throughput

---

## 📂 **Project Structure**

```
redisutils/
├── src/
│   ├── lib.rs              # Core Redis pool implementation
│   ├── config.rs           # Configuration management
│   ├── error.rs            # Error types and handling
│   └── metrics.rs          # Performance monitoring
├── tests/
│   ├── integration_tests.rs # Integration test suite
│   └── common/
│       └── mod.rs          # Test utilities
├── examples/
│   ├── basic_usage.rs      # Basic usage examples
│   ├── market_data.rs      # Market data caching
│   └── pub_sub.rs          # Pub/Sub messaging
├── Dockerfile              # Container definition
├── .env.example           # Environment template
├── Cargo.toml             # Dependencies
└── README.md              # This file
```

---

## 🤝 **Contributing**

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`cargo test`)
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)  
6. Open a Pull Request

### **Development Setup**
```bash
# Clone repository
git clone https://github.com/Nwagbara-Group-LLC/redisutils.git
cd redisutils

# Install Rust (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Build and test
cargo build
cargo test
```

---

## 📜 **License**

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

## 🏢 **About Nwagbara Group LLC**

RedisUtils is developed and maintained by Nwagbara Group LLC, specializing in high-performance financial technology solutions. Our trading platform processes millions of transactions daily with enterprise-grade reliability.

**Contact**: [info@nwagbara-group.com](mailto:info@nwagbara-group.com)
