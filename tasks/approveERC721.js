const TOKEN_CONFIG = require("../constants/tokenConfig")

module.exports = async function (taskArgs, hre) {
    let erc721Address = taskArgs.address
    if (!erc721Address) {
        const tokenConfig = TOKEN_CONFIG[hre.network.name][taskArgs.contract]
        erc721Address = tokenConfig.address

        if (!erc721Address) {
            console.error("No ERC721 contract address found or passed")
            return
        }
    }

    let spender = taskArgs.spender
    if (!spender) {
        if (!taskArgs.contract) {
            console.error("Please pass in either `spender` or `contract` param")
            return
        }

        const proxyONFT = await ethers.getContract(taskArgs.contract)
        spender = proxyONFT.address
    }

    const ERC721 = await ethers.getContractFactory("ERC721")
    const erc721 = await ERC721.attach(erc721Address)

    console.log(`ERC721 address: ${erc721Address},\n spender to approve: ${spender}`)

    let tx = await
        (await erc721.setApprovalForAll(
            spender,
            true
        )).wait()

    console.log(`approve tx success: ${tx.transactionHash}`)
}
