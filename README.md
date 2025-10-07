# RedisUtils

**Rust library providing Redis connection pooling for the Trading Platform.**

## What is this?

This is a **library**, not a standalone service.

- ❌ **NOT** a standalone microservice
- ❌ **NO** HTTP server or API
- ❌ **NO** Docker image needed
- ✅ **Library** imported by DataEngine and other services

## Usage

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

## Configuration

Set `REDIS_URL` in your environment:

```bash
# .env file (NEVER commit this!)
REDIS_URL=redis://username:password@redis-host:6379
```

## Features

- **High-Performance Pooling**: Deadpool-based connection management
- **Resilient Connectivity**: Advanced retry logic with exponential backoff
- **Production Ready**: Environment-based configuration with TLS support
- **Trading Optimized**: Designed for real-time market data and order processing

## Dependencies

- `deadpool-redis` - Async connection pooling
- `anyhow` - Error handling
- `tokio-retry` - Retry mechanisms
- `ultra-logger` - High-performance logging

## Used By

- **DataEngine** - Market data processing
- **SignalEngine** - Trading signal generation
- **BacktestingEngine** - Historical backtesting

All services import this library for Redis connectivity instead of each implementing their own connection management.

## License

Apache 2.0
