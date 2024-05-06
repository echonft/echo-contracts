// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/types/Address.sol";

// @dev Struct representing an offer item (a token)
// @dev We only support ERC721 on EVM chains for now
struct OfferItem {
    Address tokenAddress;
    uint256 tokenId;
}
