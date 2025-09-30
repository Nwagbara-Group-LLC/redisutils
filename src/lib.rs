use anyhow::{Context, Result};
use deadpool::managed::Pool;
use deadpool_redis::{Config, Connection, Manager, Runtime};
use ultra_logger::{UltraLogger, LogLevel, init_global_logger, get_global_logger};
use dotenv::dotenv;
use std::env;
use tokio_retry::{strategy::{jitter, ExponentialBackoff}, Retry};

// Initialize logger for this module
fn init_redis_logger() {
    init_global_logger("RedisUtils".to_string());
}

pub fn create_redis_pool() -> Result<Pool<Manager, Connection>> {
    init_redis_logger();
    dotenv().ok();

    let redis_url = env::var("REDIS_URL").expect("REDIS_URL must be set");
    
    // Use ultra logger for high-performance logging
    if let Some(logger) = get_global_logger() {
        logger.info_sync(format!("Creating Redis pool for URL: {}", redis_url));
    }
    
    let cfg = Config::from_url(redis_url);
    cfg.create_pool(Some(Runtime::Tokio1))
        .context("Failed to create Redis pool")
}

pub async fn get_redis_connection(pool: &Pool<Manager, Connection>) -> Result<Connection> {
    if let Some(logger) = get_global_logger() {
        logger.info_sync("Attempting to get Redis connection from pool".to_string());
    }
    
    let retry_strategy = ExponentialBackoff::from_millis(10).map(jitter).take(3);

    Retry::spawn(retry_strategy, || async {
        pool.get().await.context("Failed to get Redis connection")
    })
    .await
}

