// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/types/Address.sol";
import "contracts/types/OfferItems.sol";

enum OfferState {
    OPEN,
    ACCEPTED
}

// @dev Struct representing an on-chain offer
// TODO Should we store the id in the struct as it's already the key in the mapping
struct Offer {
    string id;
    Address sender;
    Address receiver;
    OfferItems senderItems;
    OfferItems receiverItems;
    uint64 expiration;
    OfferState state;
}
