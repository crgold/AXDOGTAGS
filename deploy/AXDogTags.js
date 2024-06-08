const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const TOKEN_CONFIG = require("../constants/tokenConfig")

const CONTRACT_NAME = "AXDogTags"

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    const tokenConfig = TOKEN_CONFIG[hre.network.name][CONTRACT_NAME]
    if (!tokenConfig.name || !tokenConfig.symbol || !tokenConfig.baseUri) {
        console.error("No configuration found for target network.")
        return
    }

    await deploy(CONTRACT_NAME, {
        from: deployer,
        args: [
            tokenConfig.name,
            tokenConfig.symbol,
            tokenConfig.baseUri,
            tokenConfig.royaltyBasePoints || 0,
            tokenConfig.minGas || 100000,
            lzEndpointAddress,
        ],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = [CONTRACT_NAME]
