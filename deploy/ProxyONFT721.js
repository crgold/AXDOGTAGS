const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

const TOKEN_ADDRESS = "0x588348d84498d0689B76F89438bE58999a5434EE"
const MIN_GAS = 100000

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)

    await deploy("ProxyONFT721", {
        from: deployer,
        args: [MIN_GAS, lzEndpointAddress, TOKEN_ADDRESS],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["ProxyONFT721"]
