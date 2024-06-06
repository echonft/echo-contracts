// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "../types/OfferItems.sol";
import "../EchoError.sol";

abstract contract EscrowState {
    // @dev Mapping to see items escrowed for an offer. The bytes32 is the offerId and owner encoded and keccak256.
    mapping(bytes32 => bool) internal _escrowedItems;

    function _generateEscrowId(bytes32 offerId, address escrowed) internal pure returns (bytes32 escrowId) {
        escrowId = keccak256(abi.encode(offerId, escrowed));
    }

    function _addToEscrow(bytes32 escrowId) internal {
        if (_escrowedItems[escrowId]) {
            revert ItemsAlreadyEscrowed();
        }
        _escrowedItems[escrowId] = true;
    }

    function _removeFromEscrow(bytes32 escrowId) internal {
        if (!_escrowedItems[escrowId]) {
            revert ItemsOutOfEscrow();
        }
        delete _escrowedItems[escrowId];
    }

    function _isInEscrow(bytes32 escrowId) internal returns (bool inEscrow) {
        inEscrow = _escrowedItems[escrowId];
    }

    modifier isInEscrow(bytes32 escrowId) {
        if (_isInEscrow(escrowId)) {
            revert ItemsOutOfEscrow();
        }
        _;
    }
}
