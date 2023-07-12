// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Admin.sol";
import "solmate/auth/Owned.sol";

// TODO Make fee changeable?
uint256 constant TradingFee = 0.005 ether;

error WithdrawFailed();

abstract contract Banker is Owned, Admin {

    /// Withdraw all funds available
    function withdraw(address account) external onlyOwner {
        (bool success, ) = account.call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }
}
