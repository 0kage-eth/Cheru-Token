const { deployments, getNamedAccounts, network, ethers } = require("hardhat")
const { assert, equal } = require("chai")
const { developmentChains } = require("../../hardhat.helper.config")

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("CheruToken tests", () => {
          let cheruToken, deployer
          beforeEach(async () => {
              deployer = await getNamedAccounts()
              await deployments.fixture(["all"])
              cheruToken = await ethers.getContract("CheruToken", deployer)
          })

          describe("CheruToken tests", () => {
              it("Check if name is correctly assigned", async () => {
                  const name = await cheruToken.name()
                  assert.equal(name, "CheruToken")
              })
          })
      })
