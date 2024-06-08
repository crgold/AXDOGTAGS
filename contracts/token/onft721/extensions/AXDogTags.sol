// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "./ExtendedONFT721.sol";

contract AXDogTags is ExtendedONFT721 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        uint96 _royaltyBasePoints,
        uint _minGasToTransfer,
        address _lzEndpoint
    ) ExtendedONFT721(_name, _symbol, _baseUri, _royaltyBasePoints, _minGasToTransfer, _lzEndpoint) {
        _setupRole(MINTER_ROLE, _msgSender());
    }

    /********************************************
     *** Public functions
     ********************************************/

    /**
     * @dev Public minting method, Minter-role only.
     */
    function mint(
        address to,
        uint tokenId,
        string memory tokenURI
    ) public virtual onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId, "");
        _setTokenURI(tokenId, tokenURI);
    }

    /**
     * @dev Multi-recipient minting.
     */
    function mintMulti(
        address[] memory recipients,
        uint[] memory tokenIds,
        string[] memory tokenURIs
    ) public virtual onlyRole(MINTER_ROLE) {
        require(recipients.length > 0 && recipients.length == tokenIds.length, "ERC721: input length mismatch");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            _safeMint(recipients[i], tokenIds[i], "");
            _setTokenURI(tokenIds[i], tokenURIs[i]);
        }
    }

    /**
     * @dev Batch-Mint (same recipient).
     */
    function mintBatch(
        address to,
        uint[] memory tokenIds,
        string[] memory tokenURIs
    ) public virtual onlyRole(MINTER_ROLE) {
        require(tokenIds.length > 0, "ERC721: tokenIds can't be empty");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i], "");
            _setTokenURI(tokenIds[i], tokenURIs[i]);
        }
    }
}
