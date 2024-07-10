// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// @dev Struct representing an offer item
// @dev We support ERC721 and ERC20
// @dev If amount is 0, then we use tokenId.
struct OfferItem {
    address tokenAddress;
    uint256 tokenId;
    uint256 amount;
}
