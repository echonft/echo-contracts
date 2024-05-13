// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./types/Offer.sol";
import "./EchoError.sol";

abstract contract EchoState {
    mapping(bytes32 => Offer) public offers;

    /**
     *  Utils
     */
    function _generateOfferId(Offer calldata offer) internal pure returns (bytes32 offerId) {
        // TODO Validate this behaviour
        offerId = keccak256(
            abi.encode(
                offer.sender,
                offer.receiver,
                offer.senderItems.chainId,
                keccak256(abi.encode(offer.senderItems.items)), // OfferItem[]
                offer.receiverItems.chainId,
                keccak256(abi.encode(offer.receiverItems.items)), // OfferItem[]
                offer.expiration
            )
        );
    }

    // @dev Internal function to check that offer data is valid for creation
    function _validateOffer(Offer calldata offer) internal view offerNotExpired(offer.expiration) {
        // @dev For future use...
        //        if (offers[offerId].sender != address(0)) {
        //            revert OfferAlreadyExist();
        //        }

        if (offer.state != OfferState.OPEN) {
            revert InvalidOfferState();
        }

        if (offer.senderItems.items.length == 0) {
            revert InvalidAssets();
        }

        if (offer.receiverItems.items.length == 0) {
            revert InvalidAssets();
        }
    }

    /**
     * Same chain offers
     */
    // @dev Internal function to create a same chain offer
    function _createOffer(Offer calldata offer, uint16 chainId) internal {
        bytes32 offerId = _generateOfferId(offer);

        _validateOffer(offer);

        // @dev Chain must be the same as contract for same chain offers
        if (offer.senderItems.chainId != chainId) {
            revert InvalidAssets();
        }

        // @dev Chain must be the same as contract for same chain offers
        if (offer.receiverItems.chainId != chainId) {
            revert InvalidAssets();
        }

        offers[offerId] = offer;
    }

    function _acceptOffer(bytes32 offerId, Offer memory offer) internal offerNotExpired(offer.expiration) {
        // @dev Cannot accept an offer if it's not OPEN
        // @dev For future use..
        //        if (offer.state != OfferState.OPEN) {
        //            revert InvalidOfferState();
        //        }
        offers[offerId].state = OfferState.ACCEPTED;
    }

    function _cancelOffer(bytes32 offerId, Offer memory offer) internal offerNotExpired(offer.expiration) {
        // @dev Cannot cancel an offer if it's not OPEN
        if (offer.state != OfferState.OPEN) {
            revert InvalidOfferState();
        }
        delete offers[offerId];
    }

    function _executeOffer(bytes32 offerId, Offer memory offer) internal offerNotExpired(offer.expiration) {
        // @dev Cannot execute an offer if it's not ACCEPTED
        // @dev For future use..
        //        if (offer.state != OfferState.ACCEPTED) {
        //            revert InvalidOfferState();
        //        }

        delete offers[offerId];
    }

    modifier offerNotExpired(uint256 expiration) {
        if (expiration <= block.timestamp) {
            revert OfferHasExpired();
        }
        _;
    }
}
