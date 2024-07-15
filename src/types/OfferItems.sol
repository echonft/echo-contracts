// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./OfferItem.sol";

// @dev Struct representing multiple offer items. We store the count for decoding purposes
struct OfferItems {
    uint256 chainId;
    OfferItem[] items;
}
