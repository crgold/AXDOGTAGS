// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// this is a MOCK
abstract contract Faucet is ERC20 {
    mapping (address => uint256) public lastClaimedAt;
    uint256 public faucetAmount = 100 * 1000000;
    uint256 public cooldownPeriod = 3600;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        _mint(msg.sender, 100000000 * 1000000);
    }

    function canClaim(address account) public view returns (bool) {
        return lastClaimedAt[account] + cooldownPeriod < block.timestamp;
    }

    function claim() external {
        require(canClaim(msg.sender), "wallet claimed recently");

        lastClaimedAt[msg.sender] = block.timestamp;
        _mint(msg.sender, faucetAmount);
    }
}

abstract contract USDFaucet is Faucet {
    function decimals() public view virtual override returns (uint8) {
        return 6;
    }
}

contract USDCMock is USDFaucet {
    constructor() Faucet("USD Coin", "USDC") {}
}

contract USDTMock is USDFaucet {
    constructor() Faucet("Tether USD", "USDT") {}
}

contract MCMock is Faucet {
    constructor() Faucet("Merit Circle", "MC") {}
}
