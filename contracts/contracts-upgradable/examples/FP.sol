// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../token/oft/v2/fee/OFTWithFeeUpgradeable.sol";
import "../token/oft/v2/fee/ProxyOFTWithFeeUpgradeable.sol";

contract FpOFT is OFTWithFeeUpgradeable {}

contract FpProxyOFT is ProxyOFTWithFeeUpgradeable {}
