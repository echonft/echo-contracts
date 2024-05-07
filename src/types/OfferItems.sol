// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/types/OfferItem.sol";

// @dev Struct representing multiple offer items. We store the count for decoding purposes
struct OfferItems {
    uint16 chainId;
    OfferItem[] items;
}
