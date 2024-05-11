// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/utils/ReentrancyGuard.sol";
import "./Admin.sol";
import "./Banker.sol";
import "./EchoError.sol";
import "./EchoState.sol";
import "./escrow/Escrow.sol";
import "./types/Offer.sol";

contract Echo is ReentrancyGuard, Admin, Banker, Escrow, EchoState {
    // @dev For future use...
    uint16 private chainId;

    constructor(address owner) Admin(owner) {
        chainId = uint16(block.chainid);
    }

    /**
     * Same chain offers
     */
    function createOffer(Offer calldata offer) external nonReentrant notPaused {
        // @dev Cannot accept an offer if not the receiver
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }
        _deposit(offer.senderItems, offer.sender);
        _createOffer(offer, chainId);
    }

    function acceptOffer(bytes32 offerId) external payable nonReentrant notPaused {
        if (msg.value != tradingFee) {
            revert InvalidPayment();
        }
        Offer memory offer = offers[offerId];

        // @dev We dont do a check on whether the offer exsits or not because
        // if it doesn't exist offer.receiver = address(0) which can't be msg.sender
        if (offer.receiver != msg.sender) {
            revert InvalidReceiver();
        }

        _deposit(offer.receiverItems, offer.receiver);
        _acceptOffer(offerId, offer);
    }

    function cancelOffer(bytes32 offerId) external nonReentrant notPaused {
        Offer memory offer = offers[offerId];

        // @dev We dont do a check on whether the offer exsits or not because
        // if it doesn't exist offer.sender = address(0) which can't be msg.sender
        if (offer.sender != msg.sender) {
            revert InvalidReceiver();
        }

        // @dev Refund sender
        _withdraw(offer.senderItems, offer.sender);
        _cancelOffer(offerId, offer);
    }

    function executeOffer(bytes32 offerId) external payable nonReentrant notPaused {
        if (msg.value != tradingFee) {
            revert InvalidPayment();
        }
        Offer memory offer = offers[offerId];

        // @dev We dont do a check on whether the offer exsits or not because
        // if it doesn't exist offer.sender = address(0) which can't be msg.sender
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }
        _withdraw(offer.senderItems, offer.receiver);
        _withdraw(offer.receiverItems, offer.sender);
        _executeOffer(offerId, offer);
    }

    // @dev Function to redeem NFTs if offer expired and trade was not executed
    function redeemOffer(bytes32 offerId) external nonReentrant notPaused {
        Offer memory offer = offers[offerId];

        if (msg.sender != offer.sender && msg.sender != offer.receiver) {
            revert InvalidRecipient();
        }

        if (offer.expiration > block.timestamp) {
            revert OfferHasNotExpired();
        }

        // @dev We know sender is either sender or receiver here, no need to check both
        if (msg.sender == offer.sender) {
            _withdraw(offer.senderItems, offer.sender);
        } else {
            _withdraw(offer.receiverItems, offer.receiver);
        }
    }
}
