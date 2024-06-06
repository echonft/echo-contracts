// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/utils/ReentrancyGuard.sol";
import "solmate/tokens/ERC721.sol";
import "./Admin.sol";
import "./Banker.sol";
import "./EchoError.sol";
import "./EchoState.sol";
import "./escrow/Escrow.sol";
import "./types/Offer.sol";

contract Echo is ReentrancyGuard, Admin, Banker, Escrow, EchoState {
    event OfferCreated(bytes32 indexed offerId);
    event OfferAccepted(bytes32 indexed offerId);
    event OfferCanceled(bytes32 indexed offerId);
    event OfferExecuted(bytes32 indexed offerId);
    event OfferRedeeemed(bytes32 indexed offerId, address indexed owner);

    // @dev For future use...
    uint256 private immutable CHAIN_ID;

    constructor(address owner) Admin(owner) {
        CHAIN_ID = block.chainid;
    }

    /**
     * Same chain offers
     */
    function createOffer(Offer calldata offer) external nonReentrant notPaused creationNotPaused {
        // @dev Cannot accept an offer if not the receiver
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }
        bytes32 offerId = _createOffer(offer, CHAIN_ID);
        _deposit(offer.senderItems, offerId, msg.sender);

        emit OfferCreated(offerId);
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
        _acceptOffer(offerId, offer);
        _deposit(offer.receiverItems, offerId, msg.sender);

        emit OfferAccepted(offerId);
    }

    function cancelOffer(bytes32 offerId)
        external
        nonReentrant
        notPaused
        isInEscrow(_generateEscrowId(offerId, msg.sender))
    {
        Offer memory offer = offers[offerId];

        // @dev We dont do a check on whether the offer exsits or not because
        // if it doesn't exist offer.sender = address(0) which can't be msg.sender
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }

        _cancelOffer(offerId, offer);
        // @dev Refund sender
        _withdraw(offer.senderItems, offerId, msg.sender);

        emit OfferCanceled(offerId);
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
        _executeOffer(offerId, offer);
        _swap(offer.senderItems, offer.sender, offer.receiverItems, offer.receiver, offerId);

        emit OfferExecuted(offerId);
    }

    // @dev Function to redeem NFTs if offer expired and trade was not executed
    function redeemOffer(bytes32 offerId)
        external
        nonReentrant
        notPaused
        isInEscrow(_generateEscrowId(offerId, msg.sender))
    {
        Offer memory offer = offers[offerId];

        if (offer.expiration > block.timestamp) {
            revert OfferHasNotExpired();
        }

        // @dev We check the escrow status of the counterparty and delete the offer if nothing is in escrow anymore
        if (msg.sender == offer.sender) {
            _withdraw(offer.senderItems, offerId, msg.sender);
            if (!_isInEscrow(_generateEscrowId(offerId, offer.receiver))) {
                delete offers[offerId];
            }
        } else if (msg.sender == offer.receiver) {
            _withdraw(offer.receiverItems, offerId, msg.sender);
            if (!_isInEscrow(_generateEscrowId(offerId, offer.sender))) {
                delete offers[offerId];
            }
        }
        emit OfferRedeeemed(offerId, msg.sender);
    }
}
