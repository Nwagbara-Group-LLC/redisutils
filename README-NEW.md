# 🔌 RedisUtils - Trading Platform Redis Library

[![Rust](https://img.shields.io/badge/rust-1.82+-orange.svg)](https://www.rust-lang.org)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

A **Rust library** providing Redis connection pooling for the Trading Platform ecosystem.

---

## 🎯 **What is this?**

**RedisUtils is a LIBRARY, not a standalone service.**

- ❌ **NOT** a standalone microservice
- ❌ **NO** HTTP server or API  
- ❌ **NO** Docker image needed (it's just a library)
- ✅ **Library** imported by DataEngine and other services for Redis connection pooling

---

## 📦 **Usage**

### **As a Library (in other Rust projects)**

```toml
# Cargo.toml
[dependencies]
redis_utils = { path = "../redisutils" }
```

```rust
use redis_utils::{create_redis_pool, get_redis_connection};
use anyhow::Result;

#[tokio::main]
async fn main() -> Result<()> {
    // Create Redis connection pool
    let pool = create_redis_pool()?;
    
    // Get connection from pool
    let mut conn = get_redis_connection(&pool).await?;
    
    // Use connection with redis commands...
    Ok(())
}
```

---

## 🔧 **Configuration**

Set in your `.env` file:

```bash
REDIS_URL=redis://127.0.0.1:6379
# or for production with auth:
REDIS_URL=redis://username:password@redis-host:6379
```

---

## 🚀 **Features**
- **High-Performance Pooling**: Deadpool-based connection management
- **Resilient Connectivity**: Advanced retry logic with exponential backoff
- **Production Ready**: Environment-based configuration with TLS support  
- **Trading Optimized**: Designed for real-time market data and order processing

---

## 📦 **Dependencies**

- `deadpool-redis` - Async connection pooling
- `anyhow` - Error handling
- `tokio-retry` - Retry mechanisms
- `ultra-logger` - High-performance logging

---

## 🤝 **Integration**

This library is used by:
- **DataEngine** - Market data processing
- **SignalEngine** - Trading signal generation  
- **BacktestingEngine** - Historical backtesting

All services import this library for Redis connectivity instead of each implementing their own connection management.
