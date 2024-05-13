// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";
import "./EchoError.sol";

/// @dev Handles ownable and pausable of contract.
abstract contract Admin is Owned {
    bool public paused;
    bool public creationPaused;

    constructor(address owner) Owned(owner) {}

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setCreationPaused(bool _creationPaused) external onlyOwner {
        creationPaused = _creationPaused;
    }

    modifier notPaused() {
        if (paused) {
            revert Paused();
        }
        _;
    }

    modifier creationNotPaused() {
        if (creationPaused) {
            revert CreationPaused();
        }
        _;
    }
}
