// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// @dev Struct representing an offer item (a token)
// @dev We only support ERC721 on EVM chains for now
struct OfferItem {
    address tokenAddress;
    uint256 tokenId;
}
