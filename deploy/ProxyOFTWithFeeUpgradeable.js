const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

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

    // MC Token address
    const TOKEN_ADDRESS_BY_NETWORK = {
        ethereum: "0x949D48EcA67b17269629c7194F4b727d4Ef9E5d6",
        fuji: "0x955723e26bd1b2165391BCaf39A92f77b30FFe01",
    }
    const tokenAddress = TOKEN_ADDRESS_BY_NETWORK[hre.network.name]
    const sharedDecimals = 6

    if (!tokenAddress) {
        console.error("No configured token address found for target network.")
        return
    }

    await deploy("ProxyOFTWithFeeUpgradeable", {
        from: deployer,
        log: true,
        waitConfirmations: 1,
        proxy: {
            owner: proxyOwner,
            proxyContract: "OptimizedTransparentProxy",
            execute: {
                init: {
                    methodName: "initialize",
                    args: [tokenAddress, sharedDecimals, lzEndpointAddress],
                },
            },
        },
    })
}

module.exports.tags = ["ProxyOFTWithFeeUpgradeable"]
