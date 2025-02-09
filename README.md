# Sample Solidity Project

## Table of Contents
1. [Introduction](#1-introduction)
2. [Prerequisites](#2-prerequisites)
3. [Contract Deployment](#3-contract-deployment)
4. [Interacting with the Contract](#4-interacting-with-the-contract)

## 1. Introduction

This project implements a simple Crowdfunding smart contract in Solidity. The contract allows users to:
- **Create a campaign:** A user (campaign creator) can start a campaign with a title, description, funding goal, and duration.
- **Contribute:** Other users can contribute funds (ETH) to the campaign.
- **Withdraw Funds:** If the campaign meets its funding goal and the deadline passes, the creator can withdraw the funds.
- **Withdraw Contribution:** If the campaign fails to meet its goal, contributors can withdraw their contributions.

The contract also emits events to log key actions (campaign creation, contributions, fund withdrawals, etc.).

## 2. Prerequisites

Before you begin, ensure you have:

- **Node.js and npm** installed (download from [nodejs.org](https://nodejs.org/)).
- **Hardhat:** A development environment to compile, deploy, and test Ethereum smart contracts.

To install Hardhat (and the recommended toolbox), run:

```sh
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
```

## 3. Contract Deployment

For testing and development, start a local Ethereum blockchain using Hardhat by running:

```sh
npx hardhat node
```

This command launches a local blockchain that simulates the Ethereum network, allowing you to deploy and interact with contracts without using real ETH.

- In a new terminal window (while the node is running), deploy your contract by running:

```sh
npx hardhat run scripts/deploy.js --network localhost
```

The deploy script will deploy the contract and save the deployed address in a file called `contractAddress.json`.

Example output:

```sh
Crowdfunding deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Contract address saved to contractAddress.json
```

## 4. Interacting with the Contract

The `interact.js` script demonstrates how to call each function in the Crowdfunding contract. A typical scenario is as follows:

- **Create a Campaign:**
	The script creates a new campaign by specifying the title, description, duration, and funding goal.

- **Contribute:**
	Two different accounts donate funds (for example, 0.3 ETH and 0.7 ETH) to the campaign.

- **Simulate Time Passage:**
	The script fast-forwards the blockchain’s time using Hardhat’s EVM commands so that the campaign deadline is reached.

- **Withdraw Funds or Contributions:**
	- If the funding goal is met, the campaign creator withdraws the funds.
	- If the goal is not met, contributors withdraw their contributions.

To run the interaction script, execute:

```sh
npx hardhat run scripts/interact.js --network localhost
```

The script logs each step to help you follow the process.
