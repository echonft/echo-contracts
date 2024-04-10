// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

struct ERC721Asset {
    address collection;
    uint64 id;
}

// @dev For simplicity sake, we only support 1 asset and we assume the offer is
// always created on another chain, thus theres only receiver asset
struct Offer {
    address sender;
    address receiver;
    uint256 expiresAt;
    OfferStatus status;
    ERC721Asset receiver721Asset;
}

enum OfferStatus {
    Created,
    Accepted,
    Cancelled
}
