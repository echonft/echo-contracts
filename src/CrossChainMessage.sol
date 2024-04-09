// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./wormhole/BytesLib.sol";

error InvalidPayloadId();
error InvalidMessageLength();

struct EchoMessage {
    // unique identifier for this message type
    uint8 payloadID;
    // arbitrary message string
    string message;
}

abstract contract CrossChainMessage {
    using BytesLib for bytes;

    /**
     * @notice Encodes the EchoMessage struct into bytes
     * @param parsedMessage EchoMessage struct with arbitrary HelloWorld message
     * @return encodedMessage EchoMessage encoded into bytes
     */
    function encodeMessage(EchoMessage memory parsedMessage) public pure returns (bytes memory encodedMessage) {
        // Convert message string to bytes so that we can use the .length attribute.
        // The length of the arbitrary messages needs to be encoded in the message
        // so that the corresponding decode function can decode the message properly.
        bytes memory encodedMessagePayload = abi.encodePacked(parsedMessage.message);

        // return the encoded message
        encodedMessage =
            abi.encodePacked(parsedMessage.payloadID, uint16(encodedMessagePayload.length), encodedMessagePayload);
    }

    /**
     * @notice Decodes bytes into EchoMessage struct
     * @dev Verifies the payloadID
     * @param encodedMessage encoded arbitrary Echo message
     * @return parsedMessage EchoMessage struct with arbitrary Echo message
     */
    function decodeMessage(bytes memory encodedMessage) public pure returns (EchoMessage memory parsedMessage) {
        // starting index for byte parsing
        uint256 index = 0;

        // parse and verify the payloadID
        parsedMessage.payloadID = encodedMessage.toUint8(index);
        if (parsedMessage.payloadID != 1) {
            revert InvalidPayloadId();
        }
        index += 1;

        // parse the message string length
        uint256 messageLength = encodedMessage.toUint16(index);
        index += 2;

        // parse the message string
        bytes memory messageBytes = encodedMessage.slice(index, messageLength);
        parsedMessage.message = string(messageBytes);
        index += messageLength;

        if (index != encodedMessage.length) {
            revert InvalidMessageLength();
        }
    }
}
