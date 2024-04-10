// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// perhaps we should have a different struct for solana chain messages?
struct EchoMessage {
    // unique identifier for this message type
    uint8 payloadID;
    // @dev id of the offer
    string id;
    // @dev EVM specific message
    bytes32 evmSender;
    bytes32 evmReceiver;
    bytes32 evmTokenAddress;
    uint64 evmTokenId;
    // @dev Solana specific message
    bytes32 solSender;
    bytes32 solReceiver;
    bytes32 solSenderTokenMint;
}

// TODO Optimize this
struct EchoMessageWithoutPayload {
    // @dev id of the offer
    string id;
    // @dev EVM specific message
    bytes32 evmSender;
    bytes32 evmReceiver;
    bytes32 evmTokenAddress;
    uint64 evmTokenId;
    // @dev Solana specific message
    bytes32 solSender;
    bytes32 solReceiver;
    bytes32 solSenderTokenMint;
}
