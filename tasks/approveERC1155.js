const TOKEN_CONFIG = require("../constants/tokenConfig")

module.exports = async function (taskArgs, hre) {
    let erc1155Address = taskArgs.address
    if (!erc1155Address) {
        const tokenConfig = TOKEN_CONFIG[hre.network.name][taskArgs.contract]
        erc1155Address = tokenConfig.address

        if (!erc1155Address) {
            console.error("No ERC1155 contract address found or passed")
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

    const ERC1155 = await ethers.getContractFactory("ERC1155")
    const erc1155 = await ERC1155.attach(erc1155Address)

    console.log(`ERC1155 address: ${erc1155Address},\n spender to approve: ${spender}`)

    let tx = await (await erc1155.setApprovalForAll(spender, true)).wait()

    console.log(`approve tx success: ${tx.transactionHash}`)
}
