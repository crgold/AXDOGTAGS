// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../ONFT721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ExtendedONFT721 is Ownable, AccessControl, ERC721, ERC721Royalty, ERC721Enumerable, ERC721Burnable, ONFT721 {
    using Strings for uint256;

    string internal baseUri;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor(string memory _name, string memory _symbol, string memory _baseUri, uint256 _minGasToTransfer, address _lzEndpoint) ONFT721(_name, _symbol, _minGasToTransfer, _lzEndpoint) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setDefaultRoyalty(_msgSender(), 200); // 2%
        baseUri = _baseUri;
    }

    /********************************************
     *** Public functions
     ********************************************/

    /**
     * @dev Public minting method, Minter-role only.
     */
    function mint(address to, uint256 tokenId) public virtual onlyRole(MINTER_ROLE) {
        _safeMint(to, tokenId, "");
    }

    /**
     * @dev Multi-recipient minting.
     */
    function mintMulti(address[] memory recipients, uint256[] memory tokenIds) public virtual onlyRole(MINTER_ROLE) {
        require(recipients.length > 0 && recipients.length == tokenIds.length, "ERC721: input length mismatch");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            _safeMint(recipients[i], tokenIds[i], "");
        }
    }

    /**
     * @dev Batch-Mint (same recipient).
     */
    function mintBatch(address to, uint256[] memory tokenIds) public virtual onlyRole(MINTER_ROLE) {
        require(tokenIds.length > 0, "ERC721: tokenIds can't be empty");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            _safeMint(to, tokenIds[i], "");
        }
    }

    /**
     * @dev Multi-recipient transfer.
     */
    function transferMulti(address from, address[] memory recipients, uint256[] memory tokenIds) public virtual {
        require(recipients.length > 0 && recipients.length == tokenIds.length, "ERC721: input length mismatch");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, recipients[i], tokenIds[i], "");
        }
    }

    /**
     * @dev Batch-Transfer (same recipient).
     */
    function transferBatch(address from, address to, uint256[] memory tokenIds) public virtual {
        require(tokenIds.length > 0, "ERC721: tokenIds can't be empty");

        for (uint16 i = 0; i < tokenIds.length; i++) {
            safeTransferFrom(from, to, tokenIds[i], "");
        }
    }

    /**
     * @dev Set new metadata host.
     */
    function setBaseURI(string memory _baseUri) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        baseUri = _baseUri;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}. Override uses `baseUri` variable and attaches ".json" extension to URI.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);

        return bytes(baseUri).length > 0 ? string(abi.encodePacked(baseUri, tokenId.toString(), ".json")) : "";
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721, ERC721Royalty, ERC721Enumerable, ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /********************************************
     *** Internal functions
     ********************************************/

    /**
     * @dev See {ERC721-_burn}.
     */
    function _burn(uint256 tokenId) internal virtual override(ERC721Royalty, ERC721) {
        super._burn(tokenId);
    }

    /**
     * @dev See {ERC721-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual override(ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }
}
