use anyhow::{Context, Result};
use deadpool::managed::Pool;
use deadpool_redis::{Config, Connection, Manager, Runtime};
use dotenv::dotenv;
use std::env;
use tokio_retry::{strategy::FixedInterval, Retry};

pub fn create_redis_pool() -> Result<Pool<Manager, Connection>> {
    dotenv().ok();

    let redis_url = env::var("REDIS_URL").expect("REDIS_URL must be set");
    let cfg = Config::from_url(redis_url);
    cfg.create_pool(Some(Runtime::Tokio1))
        .context("Failed to create Redis pool")
}

pub async fn create_redis_connection(pool: &Pool<Manager, Connection>) -> Result<Connection> {
    // Retry every 10 milliseconds, up to 15 times
    let retry_strategy = FixedInterval::from_millis(10).take(15);

    Retry::spawn(retry_strategy, || async {
        pool.get().await.context("Failed to get Redis connection")
    })
    .await
}

