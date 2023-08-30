const LZ_ENDPOINTS = require("../constants/layerzeroEndpoints.json")

const NAME = "Edenhorde"
const SYMBOL = "EH"
const BASE_URI = "https://ipfs.io/ipfs/QmbHSG2Y14wy2mSF7L57fzE4evv1BhTtUWtkzUaSnUsacB/"
const ROYALTY_BASE_POINTS = 500
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

    await deploy("ExtendedONFT721Upgradeable", {
        from: deployer,
        log: true,
        waitConfirmations: 1,
        proxy: {
            owner: proxyOwner,
            proxyContract: "OptimizedTransparentProxy",
            execute: {
                init: {
                    methodName: "initialize",
                    args: [NAME, SYMBOL, BASE_URI, ROYALTY_BASE_POINTS, MIN_GAS, lzEndpointAddress],
                },
            },
        },
    })
}

module.exports.tags = ["ExtendedONFT721Upgradeable"]
