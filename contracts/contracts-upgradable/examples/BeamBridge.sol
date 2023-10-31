// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "../token/oft/v2/fee/NativeOFTWithFeeUpgradeable.sol";
import "../token/oft/v2/fee/ProxyOFTWithFeeUpgradeable.sol";

contract BeamProxyOFT is ProxyOFTWithFeeUpgradeable {}

contract BeamNativeOFT is NativeOFTWithFeeUpgradeable {}
