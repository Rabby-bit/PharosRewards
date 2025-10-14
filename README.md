# 🧩 Contribution — Onchain Reward System

**Contribution** is a decentralized reward protocol built with **Solidity** and tested using **Foundry**.  
It lets users make contributions (in ETH or tokens), tracks their records on-chain, and rewards them transparently using an ERC20 token model.

---

## ⚙️ Tech Stack

- **Solidity (^0.8.x)** — Core smart contract logic  
- **Foundry** — Development, testing, and debugging framework  
- **Pharos Testnet** — Network used for deployment and experimentation  
- **Chainlink VRF (planned)** — For future random reward distribution  
- **Makefile (coming soon)** — To automate deployments and testing flows  

---

## 🧠 Core Features

- 💸 **Reward Distribution:** Users earn rewards automatically when they contribute  
- 🧾 **Onchain Recordkeeping:** Stores contribution details (amount, timestamp, notes)  
- 🔒 **Modular Architecture:** Separated `src/`, `test/`, and `lib/` directories for clarity  
- 🧪 **Foundry Testing Ready:** Supports `forge test` and `forge coverage`  
- ⚡ **Upgradeable Workflow:** Deployment pipeline will be automated with a Makefile  

---

## 📂 Project Structure

