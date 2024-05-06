// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct OfferCreatedMessage {
    string offerId;
    Address sender;
    Address receiver;
    OfferItems[] senderItems;
    OfferItems[] receiverItems;
    uint64 expiration;
}

struct OfferAcceptedMessage {
    string offerId;
}

struct OfferCancelledMessage {
    string offerId;
}
