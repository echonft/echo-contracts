// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// @dev Struct to represent a multichain address
struct Address {
    uint16 chainId;
    address ethAddress;
}
