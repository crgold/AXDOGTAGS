const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

const NAME = "Snakes on a chain"
const SYMBOL = "SNAKE"
const BASE_URI = "https://snake-on-a-chain-euppi.ondigitalocean.app/token/"
const MIN_GAS = 100000

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    await deploy("ExtendedONFT721", {
        from: deployer,
        args: [NAME, SYMBOL, BASE_URI, MIN_GAS, lzEndpointAddress],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["ExtendedONFT721"]
