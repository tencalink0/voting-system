import { useState, useEffect, DO_NOT_USE_OR_YOU_WILL_BE_FIRED_EXPERIMENTAL_IMG_SRC_TYPES } from 'react';
import { BrowserProvider, Contract, ethers } from 'ethers';
import { contractAddress, contractABI } from './contract';

function App() {
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [contract, setContract] = useState<Contract | null>(null);
  const [account, setAccount] = useState(null);

  useEffect(() => {
    const init = async () => {
      if ((window as any).ethereum) {
        const prov = new ethers.BrowserProvider(window.ethereum);
        const signer = await prov.getSigner();
        const ctr = new ethers.Contract(contractAddress, contractABI, signer);
        setProvider(prov);
        setContract(ctr);
        const accs = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accs[0]);
      } else {
        alert("Please install MetaMask");
      }
    };
    init();
  }, []);

  const vote = async (candidateIndex: number) => {
    if (!contract) return;
    const tx = await contract.vote(candidateIndex);
    await tx.wait();
    alert('Voted!');
  };

  return (
    <div>
      <h1>Voting DApp</h1>
      <p>A proof-of-concept voting DApp</p>
      <div className="vote-container">
        <button className="vote" onClick={() => vote(0)}>Vote for me</button>
        <button className="vote" onClick={() => vote(1)}>Vote for bev29rr</button>
      </div>
    </div>
  );
}

export default App;