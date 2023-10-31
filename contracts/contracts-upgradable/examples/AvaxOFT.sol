// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../token/oft/v2/fee/OFTWithFeeUpgradeable.sol";
import "../token/oft/v2/fee/NativeOFTWithFeeUpgradeable.sol";

contract AvaxOFT is OFTWithFeeUpgradeable {}

contract AvaxNativeOFT is NativeOFTWithFeeUpgradeable {}
