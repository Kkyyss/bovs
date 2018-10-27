var HDWalletProvider = require("truffle-hdwallet-provider");
const MNEMONIC = 'candy maple cake sugar pudding cream honey rich smooth crumble sweet treat';

module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      // must be a thunk, otherwise truffle commands may hang in CI
      provider: () =>
        new HDWalletProvider(MNEMONIC, "https://ropsten.infura.io/v3/76309cfa72c6425484b59ef79a72e029"),
      network_id: '3',
      gas: 4600000
    }
  }
};
