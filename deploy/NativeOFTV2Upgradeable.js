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

    const sharedDecimals = 6;
    const name = "Merit Circle";
    const symbol = "MC";

    await deploy("NativeOFTV2Upgradeable", {
        from: deployer,
        log: true,
        waitConfirmations: 1,
        proxy: {
            owner: proxyOwner,
            proxyContract: "OptimizedTransparentProxy",
            execute: {
                init: {
                    methodName: "initialize",
                    args: [name, symbol, sharedDecimals, lzEndpointAddress],
                },
            },
        },
    })
}

module.exports.tags = ["NativeOFTV2Upgradeable"]
