require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const ALCHEMY_API_KEY = "jEVuhuZ_STrcOiW2Hz4kZEfRFBCzH1aD";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
const PRIVATE_KEY = "db3d8d16f01f53b4d89c4d4c2e9cbd59ff1929621dbeb3a7f15fc64f3f00ed0b";

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

module.exports = {
  solidity: "0.8.4",
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: `${process.env.ETHERSCAN_KEY}`
  }

};