const { accounts, network, ethers } = require("hardhat")
const { verify } = require("../utils/verify")
const { developmentChains } = require("../hardhat.helper.config")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const chainName = network.name
    console.log("deployer", deployer)
    const inputs = ["CheruToken", "CHER", ethers.utils.parseUnits("1.0", 9)]
    const cheruToken = await deploy("CheruToken", {
        from: deployer,
        args: inputs,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    console.log("Token deployed at address:", cheruToken.address)
    console.log("cheru token contract", cheruToken)
    // console.log("token name:", (await cheruToken.name()).toString())
    // console.log("token symbol:", (await cheruToken.symbol()).toString())
    // console.log("total supply:", (await cheruToken.totalSupply()).toString())

    // console.log("balance", (await cheruToken.balanceOf(cheruToken.address)).toString())

    // verify token if chain is not a development chain
    if (!developmentChains.includes(chainName)) {
        console.log("verifying contract..please wait")

        await verify(cheruToken.address, inputs)
        console.log("Contract verified successfully")
    }
}

module.tags = ["all", "token"]
