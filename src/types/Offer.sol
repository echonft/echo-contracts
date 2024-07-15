// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./OfferItems.sol";

enum OfferState {
    OPEN,
    ACCEPTED
}

// @dev Struct representing an on-chain offer
struct Offer {
    address sender;
    address receiver;
    OfferItems senderItems;
    OfferItems receiverItems;
    uint256 expiration;
    OfferState state;
}
