// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";

error WithdrawFailed();

abstract contract Banker is Owned {
    uint256 public tradingFee = 0 ether;

    /// Withdraw all funds available
    function withdraw(address account) external onlyOwner {
        (bool success,) = account.call{value: address(this).balance}("");
        if (!success) {
            revert WithdrawFailed();
        }
    }

    function setFees(uint256 fee) external onlyOwner {
        tradingFee = fee;
    }
}
