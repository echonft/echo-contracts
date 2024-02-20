// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Echo.sol";

contract TestEcho is Echo {
    constructor(address owner) Echo(owner) {}

    function mockTradeExecution(string calldata tradeId) external {
        // Add trade to list to avoid replay and duplicates
        trades[tradeId] = true;
        emit TradeExecuted(tradeId);
    }
}
