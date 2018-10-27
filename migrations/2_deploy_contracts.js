var ElectionFactory = artifacts.require("./ElectionFactory.sol");
var Type = artifacts.require("./Type.sol");

async function doDeploy(deployer) {
  await deployer.deploy(Type);
  await deployer.link(Type, ElectionFactory);
  await deployer.deploy(ElectionFactory);
};

module.exports = (deployer, network) => {
    deployer.then(async () => {
        await doDeploy(deployer, network);
    });
};
