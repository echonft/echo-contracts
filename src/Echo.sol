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
    // @dev For future use...
    uint16 private chainId;

    constructor(address owner) Admin(owner) {
        chainId = uint16(block.chainid);
    }

    /**
     * Same chain offers
     */
    function createOffer(Offer calldata offer) external nonReentrant notPaused creationNotPaused {
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
            revert InvalidSender();
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

        // @dev no need to check for existence of offer because if deleted, the offer data points to 0
        if (msg.sender != offer.sender && msg.sender != offer.receiver) {
            revert InvalidRecipient();
        }

        if (offer.expiration > block.timestamp) {
            revert OfferHasNotExpired();
        }

        // @dev If sender, we need extra checks to make sure receiver also redeemed if offer was accepted
        if (msg.sender == offer.sender) {
            _withdraw(offer.senderItems, offer.sender);

            // @dev Receiver has escrowed only if offer was accepted
            if (offer.state == OfferState.ACCEPTED) {
                OfferItem memory receiverFirstOfferItem = offer.receiverItems.items[0];
                ERC721 receiverFirstNft = ERC721(receiverFirstOfferItem.tokenAddress);
                // @dev if Echo is not the owner, it means receiver has redeemed
                if (receiverFirstNft.ownerOf(receiverFirstOfferItem.tokenId) != address(this)) {
                    delete offers[offerId];
                }
                // @dev If offer was OPEN, receiver has not escrowed, we can safely delete
            } else {
                delete offers[offerId];
            }
        } else {
            _withdraw(offer.receiverItems, offer.receiver);
            // @dev We need to check if sender has redeemed too
            OfferItem memory senderFirstOfferItem = offer.senderItems.items[0];
            ERC721 senderFirstNft = ERC721(senderFirstOfferItem.tokenAddress);
            // @dev if Echo is not the owner, it means sender has redeemed
            if (senderFirstNft.ownerOf(senderFirstOfferItem.tokenId) != address(this)) {
                delete offers[offerId];
            }
        }
    }
}
