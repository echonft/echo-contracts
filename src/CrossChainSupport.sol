// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./CrossChainMessage.sol";
import "./wormhole/BytesLib.sol";
import "./wormhole/IWormhole.sol";
import "solmate/auth/Owned.sol";

error InvalidWormholeConfig();
error InvalidEmitterChainId();
error InvalidEmitterAddress();
error InvalidEmitter();
error FailedParsingAndVerifyingVm();
error MessageAlreadyConsumed();
error MessageTooLong();
error NotEnoughWormholeFees();

struct State {
    // address of the Wormhole contract on this chain
    address wormhole;
    // Need to store the chain ID as it might differ from the real id
    // I.e. Ethereum is chainId = 2 for Wormhole because Solana is chainId = 1
    uint16 chainId;
    /**
     * The number of block confirmations needed before the wormhole network
     * will attest a message.
     */
    uint8 wormholeFinality;
    /**
     * Wormhole chain ID to known emitter address mapping. xDapps using
     * Wormhole should register all deployed contracts on each chain to
     * verify that messages being consumed are from trusted contracts.
     */
    mapping(uint16 => bytes32) registeredEmitters;
    // verified message hash to received message mapping
    mapping(bytes32 => string) receivedMessages;
    // verified message hash to boolean
    mapping(bytes32 => bool) consumedMessages;
}

abstract contract CrossChainSupport is Owned, CrossChainMessage {
    using BytesLib for bytes;

    State private _state;

    constructor(address wormhole_, uint16 _chainId, uint8 wormholeFinality_) {
        if (wormhole_ == address(0)) {
            revert InvalidWormholeConfig();
        }
        if (_chainId == 0) {
            revert InvalidWormholeConfig();
        }
        if (wormholeFinality_ == 0) {
            revert InvalidWormholeConfig();
        }
        _state.wormhole = payable(wormhole_);
        _state.chainId = _chainId;
        _state.wormholeFinality = wormholeFinality_;
    }

    function isMessageConsumed(bytes32 hash) public view returns (bool) {
        return _state.consumedMessages[hash];
    }

    function wormholeContract() public view returns (IWormhole) {
        return IWormhole(_state.wormhole);
    }

    function _setEmitter(uint16 chainId, bytes32 emitter) internal {
        _state.registeredEmitters[chainId] = emitter;
    }

    function _consumeMessage(bytes32 hash, string memory message) internal {
        _state.receivedMessages[hash] = message;
        _state.consumedMessages[hash] = true;
    }

    /**
     * @notice Registers foreign emitters (Echo contracts) with this contract
     * @dev Only the deployer (owner) can invoke this method
     * @param emitterChainId Wormhole chainId of the contract being registered
     * See https://book.wormhole.com/reference/contracts.html for more information.
     * @param emitterAddress 32-byte address of the contract being registered. For EVM
     * contracts the first 12 bytes should be zeros.
     */
    function registerEmitter(uint16 emitterChainId, bytes32 emitterAddress) external onlyOwner {
        // sanity check the emitterChainId and emitterAddress input values
        if (emitterChainId == _state.chainId) {
            revert InvalidEmitterChainId();
        }
        if (emitterAddress == bytes32(0)) {
            revert InvalidEmitterAddress();
        }

        _setEmitter(emitterChainId, emitterAddress);
    }

    function verifyEmitter(IWormhole.VM memory vm) internal view returns (bool) {
        return _state.registeredEmitters[vm.emitterChainId] == vm.emitterAddress;
    }

    /**
     * @notice Creates an arbitrary Echo message to be attested by the
     * Wormhole guardians.
     * @dev batchID is set to 0 to opt out of batching in future Wormhole versions.
     * Reverts if:
     * - caller doesn't pass enough value to pay the Wormhole network fee
     * - `helloWorldMessage` length is >= max(uint16)
     * @param echoMessage Arbitrary Echo string
     * @return messageSequence Wormhole message sequence for this contract
     */
    function sendMessage(string memory echoMessage) public payable returns (uint64 messageSequence) {
        if (abi.encodePacked(echoMessage).length > type(uint16).max) {
            revert MessageTooLong();
        }

        IWormhole wormhole = wormholeContract();
        uint256 wormholeFee = wormhole.messageFee();

        if (msg.value != wormholeFee) {
            revert NotEnoughWormholeFees();
        }
        EchoMessage memory parsedMessage = EchoMessage({payloadID: uint8(1), message: echoMessage});

        bytes memory encodedMessage = encodeMessage(parsedMessage);

        // Send the Echo message by calling publishMessage on the
        // Wormhole core contract and paying the Wormhole protocol fee.
        messageSequence = wormhole.publishMessage{value: wormholeFee}(
            0, // batchID
            encodedMessage,
            _state.wormholeFinality
        );
    }

    /**
     * @notice Consumes arbitrary HelloWorld messages sent by registered emitters
     * @dev The arbitrary message is verified by the Wormhole core endpoint
     * `verifyVM`.
     * Reverts if:
     * - `encodedMessage` is not attested by the Wormhole network
     * - `encodedMessage` was sent by an unregistered emitter
     * - `encodedMessage` was consumed already
     * @param encodedMessage verified Wormhole message containing arbitrary
     * HelloWorld message.
     */
    function receiveMessage(bytes memory encodedMessage) public {
        // call the Wormhole core contract to parse and verify the encodedMessage
        (IWormhole.VM memory wormholeMessage, bool valid, string memory reason) =
            wormholeContract().parseAndVerifyVM(encodedMessage);

        if (!valid) {
            // TODO Add reason?
            revert FailedParsingAndVerifyingVm();
        }

        if (!verifyEmitter(wormholeMessage)) {
            revert InvalidEmitter();
        }

        EchoMessage memory parsedMessage = decodeMessage(wormholeMessage.payload);

        if (isMessageConsumed(wormholeMessage.hash)) {
            revert MessageAlreadyConsumed();
        }
        _consumeMessage(wormholeMessage.hash, parsedMessage.message);
    }
}
