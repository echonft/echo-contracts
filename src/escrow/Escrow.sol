// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./EscrowHandler.sol";
import "../types/OfferItems.sol";
import "./EscrowState.sol";

abstract contract Escrow is EscrowHandler, EscrowState {
    function _deposit(OfferItems memory offerItems, bytes32 offerId, address from) internal {
        _addToEscrow(_generateEscrowId(offerId, from));
        _transferOfferItems(offerItems, from, address(this));
    }

    function _withdraw(OfferItems memory offerItems, bytes32 offerId, address to) internal {
        _removeFromEscrow(_generateEscrowId(offerId, to));
        _transferOfferItems(offerItems, address(this), to);
    }

    function _swap(
        OfferItems memory senderItems,
        address sender,
        OfferItems memory receiverItems,
        address receiver,
        bytes32 offerId
    ) internal {
        _removeFromEscrow(_generateEscrowId(offerId, sender));
        _removeFromEscrow(_generateEscrowId(offerId, receiver));
        _transferOfferItems(senderItems, address(this), receiver);
        _transferOfferItems(receiverItems, address(this), sender);
    }
}
