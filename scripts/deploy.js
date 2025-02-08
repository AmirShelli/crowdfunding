const fs = require("fs");
const hre = require("hardhat");

async function main() {
    const Crowdfunding = await hre.ethers.getContractFactory("Crowdfunding");
    const crowdfunding = await Crowdfunding.deploy();
    await crowdfunding.waitForDeployment();

    const contractAddress = await crowdfunding.getAddress();
    console.log("Crowdfunding deployed to:", contractAddress);

    // Save contract address to a file
    fs.writeFileSync("./contractAddress.json", JSON.stringify({ address: contractAddress }, null, 2));

    console.log("Contract address saved to contractAddress.json");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
