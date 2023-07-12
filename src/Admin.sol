// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/auth/Owned.sol";

error Paused();
error NotPaused();

/// @dev Handles ownable and pausable of contract
abstract contract Admin is Owned {
    bool public newTradesPaused;
    bool public paused;

    constructor(address owner) Owned(owner) {}

    function setNewTradesPaused(bool _paused) external onlyOwner {
        newTradesPaused = _paused;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    modifier newTradesNotPaused() {
        if (newTradesPaused) {
            revert Paused();
        }

        _;
    }

    modifier notPaused() {
        if (paused) {
            revert Paused();
        }

        _;
    }

}