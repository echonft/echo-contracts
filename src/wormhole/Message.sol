// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/wormhole/BytesLib.sol";
import "contracts/wormhole/WormholeData.sol";
import "contracts/wormhole/WormholeError.sol";

abstract contract Message {
    using BytesLib for bytes;

    /**
     * @notice Encodes the EchoMessage struct into bytes
     * @param parsedMessage EchoMessage struct with arbitrary HelloWorld message
     * @return encodedMessage EchoMessage encoded into bytes
     */
    function _encodeMessage(EchoMessage memory parsedMessage) internal pure returns (bytes memory encodedMessage) {
        // Convert message string to bytes so that we can use the .length attribute.
        // The length of the arbitrary messages needs to be encoded in the message
        // so that the corresponding decode function can decode the message properly.
        bytes memory encodedId = abi.encodePacked(parsedMessage.id);

        // return the encoded message
        encodedMessage = abi.encodePacked(
            parsedMessage.payloadID,
            uint16(encodedId.length),
            encodedId,
            parsedMessage.evmSender,
            parsedMessage.evmReceiver,
            parsedMessage.evmTokenAddress,
            parsedMessage.solSender,
            parsedMessage.solReceiver,
            parsedMessage.solSenderTokenMint
        );
    }

    /**
     * @notice Decodes bytes into EchoMessage struct
     * @dev Verifies the payloadID
     * @param encodedMessage encoded arbitrary Echo message
     * @return parsedMessage EchoMessage struct with Solana trade
     */
    function _decodeMessage(bytes memory encodedMessage) internal pure returns (EchoMessage memory parsedMessage) {
        uint256 index = 0;

        // parse and verify the payloadID
        parsedMessage.payloadID = encodedMessage.toUint8(index);
        if (parsedMessage.payloadID != 1) {
            revert InvalidPayloadId();
        }
        index += 1;

        uint256 messageLength = encodedMessage.toUint16(index);
        index += 2;

        bytes memory messageBytes = encodedMessage.slice(index, messageLength);
        parsedMessage.id = string(messageBytes);
        index += messageLength;

        // EVM
        parsedMessage.evmSender = encodedMessage.toBytes32(index);
        index += 32;
        parsedMessage.evmReceiver = encodedMessage.toBytes32(index);
        index += 32;
        parsedMessage.evmTokenAddress = encodedMessage.toBytes32(index);
        index += 32;
        parsedMessage.evmTokenId = encodedMessage.toUint64(index);
        index += 8;

        // SOL
        parsedMessage.solSender = encodedMessage.toBytes32(index);
        index += 32;
        parsedMessage.solReceiver = encodedMessage.toBytes32(index);
        index += 32;
        parsedMessage.solSenderTokenMint = encodedMessage.toBytes32(index);
        index += 32;

        if (index != encodedMessage.length) {
            revert InvalidMessageLength();
        }
    }
}
