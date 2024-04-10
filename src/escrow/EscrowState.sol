// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/escrow/EscrowData.sol";

abstract contract EscrowState {
    mapping(string => bool) internal _executedTrades;
    mapping(string => Offer) internal _offers;
}
