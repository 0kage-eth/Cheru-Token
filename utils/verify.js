const { run } = require("hardhat")
const verify = async (contractAddress, args) => {
    try {
        await run("verify:verify", { address: contractAddress, constructorArguments: args })
    } catch (e) {
        if (e.msssage.toLowerCase().includes("already verified")) {
            console.log("Already verified!")
        }
        console.log(e)
    }
}

module.exports = { verify }
