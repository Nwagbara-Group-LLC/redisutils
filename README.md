# 🔌 Redis Pool Manager (Rust)

This lightweight Rust library provides functionality for creating and managing a Redis connection pool using `deadpool-redis`, complete with retry logic and `.env`-based configuration.

---

## 🚀 Features

- ✅ Creates a Redis connection pool using `deadpool-redis`
- 🔁 Includes retry logic for acquiring Redis connections (via `tokio-retry`)
- 🔐 Loads configuration using environment variables with `.env` support
- ⚡ Asynchronous and lightweight

---

## 📦 Dependencies

- [`deadpool-redis`](https://docs.rs/deadpool-redis)
- [`tokio`](https://tokio.rs/)
- [`tokio-retry`](https://docs.rs/tokio-retry)
- [`dotenv`](https://docs.rs/dotenv)
- [`anyhow`](https://docs.rs/anyhow)

---

## 📂 Project Structure

```text
.
├── lib.rs        # Core implementation for Redis pool creation and connection management
├── .env          # Environment variable file (not included in version control)
