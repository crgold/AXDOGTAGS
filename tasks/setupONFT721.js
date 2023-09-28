const setTrustedRemote = require("./setTrustedRemote")
const setMinDstGas = require("./setMinDstGas")
const TOKEN_CONFIG = require("../constants/tokenConfig")

module.exports = async function (
    { localContract, remoteContract, targetNetwork, minGas },
    hre,
) {
    let minDstGas = minGas
    if (!minDstGas) {
        if (TOKEN_CONFIG[targetNetwork] && TOKEN_CONFIG[targetNetwork][remoteContract] && TOKEN_CONFIG[targetNetwork][remoteContract].minGas) {
            minDstGas = TOKEN_CONFIG[targetNetwork][remoteContract].minGas
        } else {
            minDstGas = 100000
        }
    }

    console.log("\nsetting trusted remote...\n")
    await setTrustedRemote({
        localContract,
        remoteContract,
        targetNetwork,
    }, hre)

    console.log(`\nsetting min gas to ${minDstGas}...\n`)
    await setMinDstGas({
        contract: localContract,
        packetType: 0,
        targetNetwork,
        minGas: minDstGas,
    }, hre)

    await setMinDstGas({
        contract: localContract,
        packetType: 1,
        targetNetwork,
        minGas: minDstGas,
    }, hre)
}