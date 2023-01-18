mod config;
use log::{debug, error, info};
use tokio::signal;
use warp;
use warp::Filter;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    tracing_subscriber::fmt().json().init();

    let cfg = config::Config::from_env_and_args();
    info!("config {}:{}", cfg.ipaddr, cfg.port);

    let routes = warp::any().map(|| "Hello, World!");

    let stream = signal::ctrl_c();

    let (_, server) =
        warp::serve(routes).bind_with_graceful_shutdown((cfg.ipaddr, cfg.port), async move {
            debug!("waiting for signal");
            _ = stream.await;
            debug!("done waiting for signal");
        });

    match tokio::join!(tokio::task::spawn(server)).0 {
        Ok(()) => info!("serving"),
        Err(e) => error!("ERROR: Thread join error {}", e),
    };

    info!("terminating");
    Ok(())
}
