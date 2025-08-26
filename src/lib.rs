use anyhow::{Context, Result};
use deadpool::managed::Pool;
use deadpool_redis::{Config, Connection, Manager, Runtime};
use dotenv::dotenv;
use std::env;
use tokio_retry::{strategy::{jitter, ExponentialBackoff}, Retry};
use ultra_logger::{UltraLogger, LogLevel};

pub fn create_redis_pool() -> Result<Pool<Manager, Connection>> {
    let logger = UltraLogger::new("RedisUtils".to_string());
    dotenv().ok();

    let redis_url = env::var("REDIS_URL").expect("REDIS_URL must be set");
    // Note: Logging is synchronous here to avoid async complexity in this function
    println!("RedisUtils: Creating Redis pool for URL: {}", redis_url);
    
    let cfg = Config::from_url(redis_url);
    cfg.create_pool(Some(Runtime::Tokio1))
        .context("Failed to create Redis pool")
}

pub async fn get_redis_connection(pool: &Pool<Manager, Connection>) -> Result<Connection> {
    let logger = UltraLogger::new("RedisUtils".to_string());
    logger.log(LogLevel::Debug, "Attempting to get Redis connection from pool".to_string()).await.ok();
    
    let retry_strategy = ExponentialBackoff::from_millis(10).map(jitter).take(3);

    Retry::spawn(retry_strategy, || async {
        pool.get().await.context("Failed to get Redis connection")
    })
    .await
}

