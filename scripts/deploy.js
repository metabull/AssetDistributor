const hre = require("hardhat");

async function main() {
  const BullieverseAssetsDistributor = await hre.ethers.getContractFactory(
    "BullieverseAssetsDistributor"
  );
  const deployedBullieverseAssetsDistributor = await BullieverseAssetsDistributor.deploy("0xdbb309D8fcA8af36bD49a01C8b1Bd0b387bAE5a4"
  );

  await deployedBullieverseAssetsDistributor.deployed();

  console.log(
    "Deployed BullieverseAssetsDistributor Address:",
    deployedBullieverseAssetsDistributor.address
  );
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
