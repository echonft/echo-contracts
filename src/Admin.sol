// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";

error Paused();

/// @dev Handles ownable and pausable of contract
abstract contract Admin is Owned {
    bool public paused;

    constructor(address owner) Owned(owner) {}

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    modifier notPaused() {
        if (paused) {
            revert Paused();
        }

        _;
    }
}
