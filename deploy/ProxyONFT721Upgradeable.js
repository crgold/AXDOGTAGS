const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

const TOKEN_ADDRESS_BY_NETWORK = {
    ethereum: "0x9eEAeCBE2884AA7e82f450E3Fc174F30Fc2a8de3", // Edenhorde
    fuji: "0x588348d84498d0689B76F89438bE58999a5434EE", // Snakes
}
const MIN_GAS = 100000

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy } = deployments
    const { deployer, proxyOwner } = await getNamedAccounts()

    let lzEndpointAddress, lzEndpoint, LZEndpointMock
    if (hre.network.name === "hardhat") {
        LZEndpointMock = await ethers.getContractFactory("LZEndpointMock")
        lzEndpoint = await LZEndpointMock.deploy(1)
        lzEndpointAddress = lzEndpoint.address
    } else {
        lzEndpointAddress = LZ_ENDPOINTS[hre.network.name]
    }

    const tokenAddress = TOKEN_ADDRESS_BY_NETWORK[hre.network.name]

    await deploy("ProxyONFT721Upgradeable", {
        from: deployer,
        log: true,
        waitConfirmations: 1,
        proxy: {
            owner: proxyOwner,
            proxyContract: "OptimizedTransparentProxy",
            execute: {
                init: {
                    methodName: "initialize",
                    args: [MIN_GAS, lzEndpointAddress, tokenAddress],
                },
            },
        },
    })
}

module.exports.tags = ["ProxyONFT721Upgradeable"]
