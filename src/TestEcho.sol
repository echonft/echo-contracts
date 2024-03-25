// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Echo.sol";

// @dev Contract for development purposes only
contract TestEcho is Echo {
    constructor(address owner, address signer) Echo(owner, signer) {}

    // @dev Test emission
    function mockTradeExecution(string calldata tradeId) external {
        // Add trade to list to avoid replay and duplicates
        trades[tradeId] = true;
        emit TradeExecuted(tradeId);
    }

    // @dev Test signer signature
    function executeTrade(uint8 v, bytes32 r, bytes32 s, Signature calldata signatureData)
        external
        payable
        nonReentrant
        notPaused
    {
        _validateSignature(v, r, s, signatureData, signer);
        emit TradeExecuted("test");
    }
}
