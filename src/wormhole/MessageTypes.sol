// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * Base types for messaging
 */
// @dev Struct representing an offer item (a token)
// @dev We only support ERC721 on EVM chains for now
struct OfferItem {
    address tokenAddress;
    uint256 tokenId;
}

// @dev Struct representing multiple offer items.
// @dev We store the count for decoding purposes
struct OfferItems {
    uint8 count;
    uint16 chainId;
    OfferItem[] items;
}

/**
 * Wormhole messages types
 */
struct OfferCreatedMessage {
    bytes32 offerId;
    address sender;
    address receiver;
    OfferItems[] senderItems;
    OfferItems[] receiverItems;
    uint64 expiration;
}

struct OfferAcceptedMessage {
    bytes32 offerId;
}

struct OfferCancelledMessage {
    bytes32 offerId;
}
