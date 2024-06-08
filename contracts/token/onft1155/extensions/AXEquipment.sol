// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "../ONFT1155.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract AXEquipment is Ownable, AccessControl, ERC1155, ERC1155Burnable, ERC2981, ERC1155Supply, ONFT1155 {
    string public name = "ArmourX: Equipment";
    string public symbol = "AXE";

    /********************************************
     *** Constructor
     ********************************************/

    constructor(
        uint96 _royaltyBasePoints,
        string memory _uri,
        address _lzEndpoint
    ) ONFT1155(_uri, _lzEndpoint) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setDefaultRoyalty(_msgSender(), _royaltyBasePoints);
    }

    /********************************************
     *** Public functions
     ********************************************/

    /**
     * @dev Standard mint function.
     */
    function mint(
        address _to,
        uint _id,
        uint _amount
    ) external {
        _mint(_to, _id, _amount, "");
    }

    /**
     * @dev Function for batch minting tokens.
     */
    function mintBatch(
        address _to,
        uint[] memory _ids,
        uint[] memory _amounts
    ) external {
        _mintBatch(_to, _ids, _amounts, "");
    }

    /**
     * @dev Sets a new token metadata URI.
     */
    function setURI(string memory _uri) external virtual onlyOwner {
        _setURI(_uri);
    }

    /**
     * @dev Sets the royalty information that all ids in this contract will default to.
     */
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external virtual onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    /**
     * @dev Sets the royalty information for a specific token id, overriding the global default.
     */
    function setTokenRoyalty(
        uint tokenId,
        address receiver,
        uint96 feeNumerator
    ) external virtual onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    /**
     * @dev Transfer to multiple recipients.
     */
    function multiTransferFrom(
        address from,
        address[] memory tos,
        uint id,
        uint amount,
        bytes memory data
    ) public virtual {
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ExtendedONFT1155: caller is not token owner or approved");

        for (uint i = 0; i < tos.length; ++i) {
            _safeTransferFrom(from, tos[i], id, amount, data);
        }
    }

    /**
     * @dev Batch transfer to multiple recipients.
     */
    function multiBatchTransferFrom(
        address from,
        address[] memory tos,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) public virtual {
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ExtendedONFT1155: caller is not token owner or approved");

        for (uint i = 0; i < tos.length; ++i) {
            _safeBatchTransferFrom(from, tos[i], ids, amounts, data);
        }
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}. Includes check for token existence.
     */
    function uri(uint id) public view virtual override returns (string memory) {
        require(exists(id), "ExtendedONFT1155: Token ID doesn't exist");

        return super.uri(id);
    }

    /**
     * @dev Function for withdrawing erronously sent NFTs.
     */
    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    /**
     * @dev Function for withdrawing erronously sent tokens.
     */
    function withdrawTokens(IERC20 token) public onlyOwner {
        uint balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, ERC2981, ONFT1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /********************************************
     *** Internal functions
     ********************************************/

    /**
     * @dev See {ERC1155-_beforeTokenTransfer}.
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint[] memory ids,
        uint[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */

    uint[48] private __gap;
}
