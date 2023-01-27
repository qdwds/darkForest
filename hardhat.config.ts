import { HardhatUserConfig } from "hardhat/config";
import { config as dotenv } from "dotenv";
dotenv();
import "@nomicfoundation/hardhat-toolbox";


const config: HardhatUserConfig = {
    solidity:{
		compilers: [
			{ version: "0.8.0" },
		]
	},
    networks: {
        hardhat:{
            forking: {
				url:"https://endpoints.omniatech.io/v1/bsc/mainnet/public",
				// url: `https://bsc-mainnet.nodereal.io/v1/${process.env.NODEREAL_BSCMAIN_KEY}`,
                blockNumber: 22337426
			}
        },
    },
    paths:{
        sources:"./examples"
    }
};

export default config;
