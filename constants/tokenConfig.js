module.exports = {
  beam: {
    NativeOFTWithFeeUpgradeable: {
      name: "LayerZero Merit Circle",
      symbol: "LZMC",
    },
    ExtendedONFT721Upgradeable: {
      name: "Edenhorde",
      symbol: "EH",
      baseUri: "https://ipfs.io/ipfs/QmbHSG2Y14wy2mSF7L57fzE4evv1BhTtUWtkzUaSnUsacB/",
      royaltyBasePoints: 500,
      minGas: 100000,
    },
  },
  "beam-testnet": {
    NativeOFTWithFeeUpgradeable: {
      name: "LayerZero Wrapped Merit Circle",
      symbol: "LZMC",
    },
    NativeOFTV2: {
      name: "LayerZero Merit Circle",
      symbol: "LZMC",
    },
    ExtendedONFT721: {
      name: "Snakes on a chain",
      symbol: "SNAKE",
      baseUri: "https://snake-on-a-chain-euppi.ondigitalocean.app/token/",
      royaltyBasePoints: 500,
      minGas: 100000,
    },
  },
  ethereum: {
    ProxyOFTWithFeeUpgradeable: {
      address: "0x949D48EcA67b17269629c7194F4b727d4Ef9E5d6", // MC
    },
    ProxyONFT721Upgradeable: {
      address: "0x9eEAeCBE2884AA7e82f450E3Fc174F30Fc2a8de3", // Edenhorde Eclipse
      minGas: 100000,
    },
  },
  fuji: {
    ProxyOFTWithFeeUpgradeable: {
      address: "0x955723e26bd1b2165391BCaf39A92f77b30FFe01", // MC
    },
    ProxyONFT721: {
      address: "0x588348d84498d0689B76F89438bE58999a5434EE", // Snakes on a chain
      minGas: 100000,
    },
  }
}