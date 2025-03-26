use ethers::{
    contract::{abigen, EthAbiType},
    core::types::{Address, U256},
    middleware::SignerMiddleware,
    providers::{Http, Middleware, Provider},
    signers::{LocalWallet, Signer},
    utils::Anvil,
};

use std::{sync::Arc, time::Duration};
use tokio::time::sleep;

#[derive(Debug, Clone, EthAbiType)]
pub struct Candidate {
    name: String,
    addr: Address,
}

abigen!(Voting, "../out/Voting.sol/Voting.json");

#[tokio::main]
async fn main() -> eyre::Result<()> {
    let provider = Provider::<Http>::try_from("http://127.0.0.1:8545")?;
    let wallet: LocalWallet = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
        .parse::<LocalWallet>()?
        .with_chain_id(31337 as u64);

    let client = Arc::new(SignerMiddleware::new(provider.clone(), wallet.clone()));


    let candidates: Vec<Candidate> = vec![
    Candidate {
        name: "Tenca".to_string(),
        addr: "0x0000000000000000000000000000000000000001".parse()?,
    },
    Candidate {
        name: "Link0".to_string(),
        addr: "0x0000000000000000000000000000000000000002".parse()?,
    },
];


    let contract = Voting::deploy(client.clone(), (candidates.clone(), U256::from(60)))?
        .send()
        .await?;

    println!("Contract deployed at: {:?}", contract.address());

    let candidate_addr = candidates[0].addr; // index 0, item addr (address of candidate)

    let binding = contract.vote(candidate_addr);
    let tx = binding
        .send()
        .await?;
    tx.await?; // must call double await as block is being created 

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