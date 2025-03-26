use ethers::{
    contract::abigen,
    core::types::{Address, U256},
    middleware::SignerMiddleware,
    providers::{Http, Middleware, Provider},
    signers::{LocalWallet, Signer},
    utils::Anvil,
};

use std::{sync::Arc, time::Duration};
use tokio::time::sleep;

abigen!(Voting, "../out/Voting.sol/Voting.json");

#[tokio::main]
async fn main() -> eyre::Result<()> {
    let provider = Provider::<Http>::try_from("http://127.0.0.1:8545")?;
    let wallet: LocalWallet = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
        .parse::<LocalWallet>()?
        .with_chain_id(31337 as u64);

    let client = Arc::new(SignerMiddleware::new(provider.clone(), wallet.clone()));


    let candidates = vec![
        ("Alice".to_string(), Address::random()),
        ("Bob".to_string(), Address::random()),
    ];


    let contract = Voting::deploy(client.clone(), (candidates.clone(), U256::from(60)))?
        .send()
        .await?;

    println!("Contract deployed at: {:?}", contract.address());

    let candidate_addr = candidates[0].1; // index 0, item 1 (addr)

    let binding = contract.vote(candidate_addr);
    let tx = binding
        .send()
        .await?;
    tx.await?;

    println!("Voted for candidate 1");

    let votes: U256 = contract
        .votes(candidate_addr)
        .call()
        .await?;
    println!("Votes for candidate 1: {}", votes);
    assert_eq!(votes, U256::from(1));

    println!("Waiting for voting period to end...");
    sleep(Duration::from_secs(61)).await;

    let (winners, max_votes): (Vec<Address>, U256) = contract.find_winners().call().await?;
    println!("Winners: {:?} with {} votes", winners, max_votes);

    Ok(())
}