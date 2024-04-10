// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";

error Paused();
error InvalidAddress();

/// @dev Handles ownable and pausable of contract.
/// Also manages the signer address to validate trades
abstract contract AdminSigner is Owned {
    bool public paused;
    address public signer;

    constructor(address owner, address _signer) Owned(owner) {
        signer = _signer;
    }

    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
    }

    function setSigner(address _signer) external onlyOwner {
        if (_signer == address(0)) revert InvalidAddress();
        signer = _signer;
    }

    modifier notPaused() {
        if (paused) {
            revert Paused();
        }

        _;
    }
}
