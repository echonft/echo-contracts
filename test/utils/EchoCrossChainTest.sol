// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/EchoCrossChain.sol";
import "contracts/wormhole/WormholeData.sol";

contract EchoCrossChainTest is EchoCrossChain {
    constructor(address owner, address wormhole, uint16 chainId, uint8 wormholeFinality)
        EchoCrossChain(owner, wormhole, chainId, wormholeFinality)
    {}

    function sendMessage(EchoMessageWithoutPayload memory message) public payable returns (uint64 messageSequence) {
        return _sendMessage(message);
    }

    function receiveMessage(bytes memory encodedMessage) public returns (EchoMessage memory parsedMessage) {
        return _receiveMessage(encodedMessage);
    }
}
