
import "@nomiclabs/hardhat-waffle";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan"
import "hardhat-gas-reporter"

import dotenv from "dotenv";

dotenv.config({ path: ".env.local" });


export default {
  solidity: {
    version: "0.8.12",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "goerli",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    mumbai: {
      url: process.env.MUMBAI_URL || '',
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
      
  },
  goerli: {
    url: `https://eth-goerli.g.alchemy.com/v2/V5p1PckEwUqIq5s5rA2zvwRKH0V9Hslr`,
    accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : ["6923720ab043d19f5975644c6312f0de7ffbe7bc446c871abde2c078eaeae53f"]
  }
  },
  etherscan: {
    apiKey: "2S8CM6KUUPXGG7JV63UZVVVZTWP6RYJXYE"
 }
};