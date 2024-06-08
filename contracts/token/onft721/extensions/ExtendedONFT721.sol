// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../ONFT721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ExtendedONFT721 is Ownable, AccessControl, ERC721, ERC721Royalty, ERC721Enumerable, ERC721Burnable, ERC721URIStorage, ONFT721 {
    using Strings for uint;

    string internal baseTokenURI;
    mapping(uint => string) private _tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        uint96 _royaltyBasePoints,
        uint _minGasToTransfer,
        address _lzEndpoint
    ) ONFT721(_name, _symbol, _minGasToTransfer, _lzEndpoint) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setDefaultRoyalty(_msgSender(), _royaltyBasePoints);
        baseTokenURI = _baseUri;
    }

    /********************************************
     *** Public functions
     ********************************************/

    /**
     * @dev Multi-recipient transfer.
     */
    function transferMulti(
        address from,
        address[] memory recipients,
        uint[] memory tokenIds
    ) public virtual {
        require(recipients.length > 0 && recipients.length == tokenIds.length, "ERC721: input length mismatch");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, recipients[i], tokenIds[i], "");
        }
    }

    /**
     * @dev Batch-Transfer (same recipient).
     */
    function transferBatch(
        address from,
        address to,
        uint[] memory tokenIds
    ) public virtual {
        require(tokenIds.length > 0, "ERC721: tokenIds can't be empty");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, to, tokenIds[i], "");
        }
    }

    /**
     * @dev Set new token metadata base URI.
     */
    function setBaseURI(string memory _baseUri) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        baseTokenURI = _baseUri;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ONFT721, ERC721Royalty, ERC721Enumerable, ERC721, AccessControl, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /********************************************
     *** Internal functions
     ********************************************/

    /**
     * @dev Updateable base token URI override.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @dev See {ERC721-_burn}. This override additionally checks to see if a
     * token-specific URI was set for the token, and if so, it deletes the token URI from
     * the storage mapping.
     */
    function _burn(uint tokenId) internal virtual override(ERC721Royalty, ERC721, ERC721URIStorage) {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint firstTokenId,
        uint batchSize
    ) internal virtual override(ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
