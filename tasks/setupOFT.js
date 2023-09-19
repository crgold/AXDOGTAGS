const setTrustedRemote = require("./setTrustedRemote")
const setMinDstGas = require("./setMinDstGas")
const setCustomAdapterParams = require("./setCustomAdapterParams")

module.exports = async function (
    { localContract, remoteContract, targetNetwork, minGas },
    hre,
) {
    console.log("\nsetting trusted remote...\n")
    await setTrustedRemote({
        localContract,
        remoteContract,
        targetNetwork,
    }, hre)

    console.log("\nsetting min gas...\n")
    await setMinDstGas({
        contract: localContract,
        packetType: 0,
        targetNetwork,
        minGas,
    }, hre)

    await setMinDstGas({
        contract: localContract,
        packetType: 1,
        targetNetwork,
        minGas,
    }, hre)

    console.log("\nsetting custom adapter params...\n")
    await setCustomAdapterParams({
        contract: localContract,
    }, hre)
}