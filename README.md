# HorizonTechX Blockchain Development Internship

## Project Overview
This repository contains 4 Solidity smart contracts completed as part of my Horizon TechX Blockchain Development Internship.

## Tasks Completed

### ✅ Task 1: Simple Storage Smart Contract
- Stores an integer value on the blockchain
- Includes increment (+1) and decrement (-1) functions
- Publicly readable value with event logging
- Underflow protection on decrement

### ✅ Task 2: Multi-Send Smart Contract
- Accepts an array of Ethereum addresses
- Receives Ether via payable function
- Distributes equal amounts to all recipients using a loop
- Secure transfers with reentrancy-safe call pattern
- Owner-only access control and emergency withdrawal

### ✅ Task 3: Polling System Smart Contract
- Create polls with title, options, and deadline
- One vote per address enforced via mappings
- Winner declaration after deadline passes
- Time remaining tracking and vote counting

### ✅ Task 4: Crypto Locking Smart Contract
- Deposit Ether with a customizable lock-in period
- Time validation using `block.timestamp`
- Withdrawal only allowed after lock period ends
- Early withdrawal prevention with clear error messages
- Lock extension capability

## Tech Stack
- **Language:** Solidity ^0.8.19
- **IDE:** Remix IDE
- **Network:** Ethereum (Sepolia Testnet for deployment)

## How to Deploy & Test (Remix IDE)

1. Go to [https://remix.ethereum.org](https://remix.ethereum.org)
2. Create a new file for each contract
3. Compile with Solidity 0.8.19+
4. Deploy using Injected Provider (MetaMask) on Sepolia

## Testing Quick Guide

| Task | Test Steps |
|------|-----------|
| **Task 1** | `setValue(100)` → `increment()` → `getValue()` returns 101 → `decrement()` → returns 100 |
| **Task 2** | Send 0.3 ETH → `distributeEqual([addr1, addr2, addr3])` → each gets 0.1 ETH |
| **Task 3** | `createPoll("Best Chain?", ["ETH","SOL","ADA"], 2)` → `vote(0,1)` → wait 2 min → `declareWinner(0)` |
| **Task 4** | `deposit(1)` with 0.5 ETH → `getMyLock()` → `withdraw()` reverts → wait 1 min → succeeds |

## Sepolia Faucets
- [Alchemy Faucet](https://www.alchemy.com/faucets/ethereum-sepolia)
- [QuickNode Faucet](https://www.quicknode.com/faucets)
- [Infura Faucet](https://www.infura.io/faucet/sepolia)

## License
MIT
