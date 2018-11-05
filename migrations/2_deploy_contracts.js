var ElectionFactory = artifacts.require("./ElectionFactory.sol");
var Library = artifacts.require("./Library.sol");
var strings = artifacts.require("./strings.sol");

async function doDeploy(deployer) {
  await deployer.deploy(Library);
  await deployer.link(Library, ElectionFactory);
  await deployer.deploy(strings);
  await deployer.link(strings, ElectionFactory);
  await deployer.deploy(ElectionFactory);
};

module.exports = (deployer, network) => {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
