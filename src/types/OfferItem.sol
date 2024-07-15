// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

enum TokenType {
    ERC20,
    ERC721
}

// @dev Struct representing an offer item
// @dev We support ERC721 and ERC20
struct OfferItem {
    address tokenAddress;
    TokenType tokenType;
    uint256 tokenIdOrAmount;
}
