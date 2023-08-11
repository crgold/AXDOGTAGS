const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")
const {ethers} = require("hardhat");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer } = await getNamedAccounts()
    console.log(`>>> your address: ${deployer}`)

    const lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    console.log(`[${hre.network.name}] Endpoint Address: ${lzEndpointAddress}`)
    const tokenAddress = "0x955723e26bd1b2165391BCaf39A92f77b30FFe01";
    const sharedDecimals = 6;

    await deploy("ProxyOFTV2", {
        from: deployer,
        args: [tokenAddress, sharedDecimals, lzEndpointAddress],
        log: true,
        waitConfirmations: 1,
    })
}

module.exports.tags = ["ProxyOFTV2"]
