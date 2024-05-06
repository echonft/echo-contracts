// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/types/Offer.sol";

error OfferAlreadyExist();
error OfferDoesNotExist();
error OfferHasExpired();
error InvalidAssets();
error InvalidCounterparty();
error InvalidCreator();
error InvalidOfferState();

abstract contract EchoState {
    mapping(string => Offer) internal _offers;

    // @dev Internal function to create the offer state. We don't do a check on the addresses here
    // because it might be triggered from a cross chain call. The check is done in the main Echo contract
    function _createOffer(Offer calldata offer) internal payable {
        if (_offers[offer.id].sender != address(0)) {
            revert OfferAlreadyExist();
        }

        if (offer.expiration <= block.timestamp) {
            revert OfferHasExpired();
        }
        if (offer.state != OfferState.OPEN) {
            revert InvalidOfferState();
        }

        // @dev We validate that the offer data is valid
        uint8 senderItemsLength = offer.senderItems.items.length;
        if (offer.senderItems.count != senderItemsLength || senderItemsLength == 0) {
            revert InvalidAssets();
        }

        uint8 receiverItemsLength = offer.receiverItems.items.length;
        if (offer.receiverItems.count != receiverItemsLength || receiverItemsLength == 0) {
            revert InvalidAssets();
        }

        _offers[offer.id] = offer;
    }

    function _acceptOffer(string calldata offerId) internal {
        if (_offers[offerId].sender == address(0)) {
            revert OfferDoesNotExist();
        }
        Offer offer = _offers[offerId];

        // @dev Cannot accept an offer if not the receiver
        if (offer.receiver.ethAddress != msg.sender) {
            revert InvalidCounterparty();
        }

        if (offer.expiration <= block.timestamp) {
            revert OfferHasExpired();
        }
        // @dev Cannot accept an offer if it's not OPEN
        if (offer.state != OfferState.OPEN) {
            revert InvalidOfferState();
        }
        _offers[offerId].state = OfferState.ACCEPTED;
    }

    function _executeOffer(string calldata offerId) internal {
        if (_offers[offerId].sender == address(0)) {
            revert OfferDoesNotExist();
        }
        Offer offer = _offers[offerId];

        if (offer.expiration <= block.timestamp) {
            revert OfferHasExpired();
        }
        // @dev Cannot execute an offer if it's not ACCEPTED
        if (offer.state != OfferState.ACCEPTED) {
            revert InvalidOfferState();
        }

        delete _offers[offerId];
    }
}
