// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../token/oft/v2/fee/OFTWithFeeUpgradeable.sol";

contract UsdtOFT is OFTWithFeeUpgradeable {
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}
