//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MalibuCoinI is IERC20, Ownable {
        function getUnclaimedMalibuCoins(address account) external view virtual returns (uint256 amount);
}
