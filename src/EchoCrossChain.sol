// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/Admin.sol";
import "contracts/Banker.sol";
import "contracts/EchoState.sol";
import "contracts/MessageValidator.sol";
import "contracts/escrow/Escrow.sol";
import "contracts/types/Offer.sol";
import "contracts/wormhole/WormholeGovernance.sol";
import "solmate/utils/ReentrancyGuard.sol";

error InvalidSender();
error InvalidReceiver();
error InvalidPayment();

contract EchoCrossChain is ReentrancyGuard, Admin, Banker, Escrow, WormholeGovernance, EchoState, MessageValidator {
    constructor(address owner, address wormhole, uint16 chainId, uint8 wormholeFinality)
        Admin(owner)
        WormholeGovernance(wormhole, chainId, wormholeFinality)
    {}

    /**
     * Same chain offers
     */
    function createOffer(Offer calldata offer) external payable nonReentrant notPaused {
        // @dev Cannot accept an offer if not the receiver
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }
        _deposit(offer.senderItems, offer.sender);
        _createOffer(offer, _state.chainId);
    }

    function createCrossChainOffer(Offer calldata offer) external payable nonReentrant notPaused {
        // @dev Cannot accept an offer if not the receiver
        if (offer.sender != msg.sender) {
            revert InvalidSender();
        }
    }

    // @dev This function assumes that the offer was created on another chain.
    function acceptOffer(string calldata offerId, Offer calldata offer, bytes memory encodedMessage)
        external
        payable
        nonReentrant
        notPaused
    {
        //        if (_offers[offerId].sender != address(0)) {
        //            revert OfferAlreadyExist();
        //        }
        //        // @dev Cannot accept an offer if not the receiver
        //        if (offer.receiver != msg.sender) {
        //            revert InvalidCounterparty();
        //        }
        //
        //        if (offer.expiresAt <= block.timestamp) {
        //            revert OfferHasExpired();
        //        }
        //
        //        if (offer.status != OfferStatus.Created) {
        //            revert InvalidOfferStatus();
        //        }
        //
        //        // Validate that the offer was created on the other chain
        //        EchoMessage memory message = _receiveMessage(encodedMessage);
        //        _validateMessage(message, offer);
        //
        //        _depositForReceiver(offer);
        //        _offers[offerId] = offer;
        //
        //        // @dev FIXME the message should change
        //        EchoMessageWithoutPayload memory newMessage = EchoMessageWithoutPayload({
        //            id: message.id,
        //            evmSender: message.evmSender,
        //            evmReceiver: message.evmReceiver,
        //            evmTokenAddress: message.evmTokenAddress,
        //            evmTokenId: message.evmTokenId,
        //            solSender: message.solSender,
        //            solReceiver: message.solReceiver,
        //            solSenderTokenMint: message.solSenderTokenMint
        //        });
        //        _sendMessage(newMessage);
    }

    function executeTrade() external payable nonReentrant notPaused {
        //        if (trades[trade.id]) {
        //            revert TradeAlreadyExist();
        //        }
        //
        //        if (trade.creator != msg.sender) {
        //            revert InvalidCreator();
        //        }
        //
        //        // We only check that length is not 0 here because we check the length in the transfer method
        //        if (trade.creatorCollections.length == 0 || trade.counterpartyCollections.length == 0) {
        //            revert InvalidAssets();
        //        }
        //
        //        if (trade.expiresAt <= block.timestamp) {
        //            revert TradeHasExpired();
        //        }
        //
        //        if (msg.value != tradingFee) {
        //            revert InvalidPayment();
        //        }
        //
        //        _validateSignature(v, r, s, signatureData, signer);
        //        _validateTrade(signatureData, trade);
        //
        //        // Transfer creator's assets
        //        _transferTokens({
        //            collections: trade.creatorCollections,
        //            ids: trade.creatorIds,
        //            from: trade.creator,
        //            to: trade.counterparty
        //        });
        //
        //        // Transfer counterparty's assets
        //        _transferTokens({
        //            collections: trade.counterpartyCollections,
        //            ids: trade.counterpartyIds,
        //            from: trade.counterparty,
        //            to: trade.creator
        //        });
        //
        //        // Add trade to list to avoid replay and duplicates
        //        trades[trade.id] = true;
        //        emit TradeExecuted(trade.id);
    }

    //    // @dev Wormhole function to receive messages and update trades
    //    function receiveMessage(
    //        bytes memory encodedMessage
    //    ) public returns (EchoMessage memory parsedMessage) {
    //        parsedMessage = _receiveMessage(encodedMessage);
    //    }
}
