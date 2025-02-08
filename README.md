# Sample Solidity Project

## 1. Introduction

This project implements a simple Crowdfunding smart contract in Solidity. The contract allows users to:
- **Create a campaign:** A user (campaign creator) can start a campaign with a title, description, funding goal, and duration.
- **Contribute:** Other users can contribute funds (ETH) to the campaign.
- **Withdraw Funds:** If the campaign meets its funding goal and the deadline passes, the creator can withdraw the funds.
- **Withdraw Contribution:** If the campaign fails to meet its goal, contributors can withdraw their contributions.

The contract also emits events to log key actions (campaign creation, contributions, fund withdrawals, etc.).

## 2. Prerequisites

Before you begin, make sure you have:

- **Node.js and npm** installed (download from [nodejs.org](https://nodejs.org/)).
- **Hardhat:** A development environment to compile, deploy, and test Ethereum smart contracts.

To install Hardhat (and the recommended toolbox), run:
```sh
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox
```

## 3. Contract Deployment

- To ---, start a local Ethereum blockchain using hardhat with the following command:
```sh
npx hardhat node
```
- In a new terminal window (while the node is running), deploy your contract by running:

```sh
npx hardhat run scripts/deploy.js --network localhost
```
The deploy script will deploy the contract and save the deployed address in a file called contractAddress.json.

Example output:
```sh
Crowdfunding deployed to: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
Contract address saved to contractAddress.json
```
## 4. Interacting with the Contract

The interaction script (interact.js) demonstrates how to call each function in the Crowdfunding contract. In the following example, the scenario goes as follows:

-
-
-
-

to run the interaction script, run the following script:

```sh
npx hardhat run scripts/interact.js --network localhost
```

The script logs each step so you can follow what’s happening.
