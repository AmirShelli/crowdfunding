const fs = require("fs");
const hre = require("hardhat");

async function main() {
    console.log("🚀 Starting interaction script...");

    // Read contract address
    const contractData = fs.readFileSync("./contractAddress.json", "utf-8");
    const { address: contractAddress } = JSON.parse(contractData);
    console.log(`📜 Using contract at address: ${contractAddress}`);

    const [owner, contributor1, contributor2] = await hre.ethers.getSigners();
    console.log(`🔑 Using signer: ${owner.address}`);

    const crowdfunding = await hre.ethers.getContractAt("Crowdfunding", contractAddress);
    console.log("✅ Contract connected!");

    // Get initial number of campaigns
    let campaignCount;
    try {
        campaignCount = await crowdfunding.getCampaignsCount();
        console.log(`📊 Campaign count before creation: ${campaignCount}`);
    } catch (error) {
        console.error("❌ Failed to get campaign count:", error.reason || error);
        return;
    }

    // Create a new campaign
    console.log("🛠️ Creating a new campaign...");
    const duration = 86400; // Set duration to 24h (in seconds)
    console.log(`🕒 Setting campaign duration to: ${duration} seconds`);
    try {
        const txCreate = await crowdfunding.createCampaign(
            "Test Campaign",
            "This is a test crowdfunding campaign",
            duration,
            hre.ethers.parseUnits("1.3", "ether") // Change goal to < 1 ETH to test goal not reached scenario
        );
        await txCreate.wait();
        console.log("✅ Campaign created!");
    } catch (error) {
        console.error("❌ Campaign creation failed:", error.reason || error);
        return;
    }

    // Get updated campaign count
    try {
        campaignCount = await crowdfunding.getCampaignsCount();
        console.log(`📊 Updated campaign count: ${campaignCount}`);
    } catch (error) {
        console.error("❌ Failed to get updated campaign count:", error.reason || error);
        return;
    }

    // Contribute to the campaign
    const lastCampaignId = campaignCount - 1n; // Use BigInt for campaign ID
    console.log(`💰 Contributing 0.3 ETH to campaign ${lastCampaignId} from ${contributor1.address}...`);
    await makeContribution(crowdfunding, contributor1, lastCampaignId, "0.3");

    console.log(`💰 Contributing 0.7 ETH to campaign ${lastCampaignId} from ${contributor2.address}...`);
    await makeContribution(crowdfunding, contributor2, lastCampaignId, "0.7");

    // Wait for campaign to end
    console.log("⏳ Waiting for campaign to end...");
    await fastForward(24 * 60 * 60);

    // Retrieve the current block timestamp
    const block = await hre.ethers.provider.getBlock("latest");
    const currentTime = block.timestamp;
    const campaign = await crowdfunding.campaigns(lastCampaignId);
    console.log(`Current time: ${currentTime}, Campaign deadline: ${campaign.deadline}`);
    console.log(`Campaign details:`, campaign);
    if (currentTime < campaign.deadline) {
        console.log("⏳ Campaign deadline not yet passed, skipping withdrawal...");
        return;
    }

    // Withdraw funds (if goal reached)
    if (campaign.totalFunds >= campaign.goal) {
        console.log("💸 Attempting to withdraw funds...");
        await attemptWithdrawal(crowdfunding, lastCampaignId);
    } else {
        console.log("⚠️ Campaign goal not reached, contributors can withdraw their contributions.");

        // Withdraw contribution for contributor1 (if goal was not met)
        console.log("🔄 Attempting to withdraw contribution...");
        await attemptContributionWithdrawal(crowdfunding, contributor1, lastCampaignId);
    }

    console.log("✅ Interaction completed!");
}

async function fastForward(seconds) {
    console.log(`⏩ Fast forwarding time by ${seconds} seconds...`);
    await hre.network.provider.send("evm_increaseTime", [seconds]);
    await hre.network.provider.send("evm_mine");
}

async function makeContribution(contract, signer, campaignId, amount) {
    try {
        const tx = await contract.connect(signer).contribute(campaignId, {
            value: hre.ethers.parseUnits(amount, "ether"),
        });
        await tx.wait();
        console.log(`✅ Contribution of ${amount} ETH from ${signer.address} successful!`);
    } catch (error) {
        console.error(`❌ Contribution failed for ${signer.address}:`, error.reason || error);
    }
}

async function attemptWithdrawal(contract, campaignId) {
    try {
        const tx = await contract.withdrawFunds(campaignId);
        await tx.wait();
        console.log("✅ Funds withdrawn successfully!");
    } catch (error) {
        console.error("❌ Withdrawal failed:", error.reason || error);
    }
}

async function attemptContributionWithdrawal(contract, signer, campaignId) {
    try {
        const tx = await contract.connect(signer).withdrawContribution(campaignId);
        await tx.wait();
        console.log(`✅ Contribution withdrawn successfully for ${signer.address}!`);
    } catch (error) {
        console.error(`❌ Contribution withdrawal failed for ${signer.address}:`, error.reason || error);
    }
}

main().catch((error) => {
    console.error("❌ Script failed:", error);
    process.exit(1);
});
