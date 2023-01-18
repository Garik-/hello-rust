use clap::Parser;
use dotenv::dotenv;
use std::net::Ipv4Addr;

/// My Awesome Application
#[derive(Parser, Debug)]
#[command(author, version, about)]
pub struct Config {
    /// IPv4 address
    #[arg(short, long, env("HELLO_RUST_ADDR"), default_value = "0.0.0.0")]
    pub ipaddr: Ipv4Addr,

    /// Port number
    #[arg(short, long, env("HELLO_RUST_PORT"), default_value_t = 3000)]
    pub port: u16,
}

impl Config {
    pub fn from_env_and_args() -> Self {
        dotenv().ok();
        Self::parse()
    }
}
