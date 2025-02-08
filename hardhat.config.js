require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.19" },
      { version: "0.8.28" },
	  { version: "0.8.26" },
    ]
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545"
    }
}
};
