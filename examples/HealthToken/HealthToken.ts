import { ethers } from "hardhat";
import {  bsc8Address, WBNBAddress } from "../../config/address";
import { parseUnits } from "ethers/lib/utils";


async function main() {
    const HealthTokenFlashSwap = await ethers.getContractFactory("HealthTokenFlashSwap");
    const healthTokenFlashSwap = await HealthTokenFlashSwap.deploy();
    const healthFlashSwap = await healthTokenFlashSwap.deployed();

    const [signer] = await ethers.getSigners();
    const bsc8 = await ethers.getImpersonatedSigner(bsc8Address);
    console.log(await bsc8.getBalance())
    console.log(await bsc8.provider?.getBlockNumber())
    await bsc8.sendTransaction({
        to: signer.address,
        value: parseUnits("1")
    }),

    await healthFlashSwap.flashSwap(WBNBAddress, parseUnits("40"), { gasLimit: 30000000 });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
