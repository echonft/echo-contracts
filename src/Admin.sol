// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";

error Paused();

/// @dev Handles ownable and pausable of contract.
/// Also manages the signer address to validate trades
abstract contract Admin is Owned {
    bool public paused;
    address public signer;

    constructor(address owner, address _signer) Owned(owner) {
        signer = _signer;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setSigner(address _signer) external onlyOwner {
        signer = _signer;
    }

    modifier notPaused() {
        if (paused) {
            revert Paused();
        }

        _;
    }
}
