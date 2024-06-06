// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./EscrowHandler.sol";
import "../types/OfferItems.sol";
import "./EscrowState.sol";

abstract contract Escrow is EscrowHandler, EscrowState {
    function _deposit(OfferItems memory offerItems, bytes32 offerId, address from) internal {
        _transferOfferItems(offerItems, from, address(this));
        _addToEscrow(_generateEscrowId(offerId, from));
    }

    function _withdraw(OfferItems memory offerItems, bytes32 offerId, address to) internal {
        _transferOfferItems(offerItems, address(this), to);
        _removeFromEscrow(_generateEscrowId(offerId, to));
    }
}
