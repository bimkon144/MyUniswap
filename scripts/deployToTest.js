
const hre = require("hardhat");

async function main() {

  const [owner, user, addr2] = await hre.ethers.getSigners();

  const Token0 = await hre.ethers.getContractFactory("BimkonToken");
  const token0 = await Token0.deploy("BimkonToken", "BTK", 10500);
  console.log("BimkonToken address:", token0.address);

  const Token1 = await hre.ethers.getContractFactory("WorldToken");
  const token1 = await Token1.deploy("WorldToken", "WTK", 10500);
  const balanceOfToken1 = await token1.balanceOf(owner.address);
  console.log("WorldToken address:", token1.address);


  //deploy router
  const Router = await hre.ethers.getContractFactory("Router");
  const router = await Router.deploy();
  await router.deployed();
  console.log("Router address:", router.address);

  //deploy factory
  const Factory = await hre.ethers.getContractFactory("Factory");
  const factory = await Factory.deploy();
  await factory.deployed();
  console.log("Factory address:", factory.address);
  //deploy registry
  const Registry = await hre.ethers.getContractFactory("Registry");
  const registry = await Registry.deploy();
  await registry.deployed();
  console.log("Registry address:", registry.address);

  //deploy feeContact
  const FeeParameters = await hre.ethers.getContractFactory("FeeParameters");
  const feeParameters = await FeeParameters.deploy();
  await feeParameters.deployed();
  console.log("FeeOaraneters address:", feeParameters.address);

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
