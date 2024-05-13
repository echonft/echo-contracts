// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/auth/Owned.sol";
import "./Message.sol";
import "./WormholeError.sol";
import "./WormholeState.sol";
import "../../lib/wormhole/IWormhole.sol";

abstract contract WormholeGovernance is Owned, Message, WormholeState {
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

    //    /**
    //     * @notice Sends an EchoMessage
    //     * @dev batchID is set to 0 to opt out of batching in future Wormhole versions.
    //     * Reverts if:
    //     * - caller doesn't pass enough value to pay the Wormhole network fee
    //     * @param message EchoMessageWithoutPayload to send
    //     * @return messageSequence Wormhole message sequence for this contract
    //     */
    //    function _sendMessage(
    //        EchoMessageWithoutPayload memory message
    //    ) internal hasEnoughWormholeFees returns (uint64 messageSequence) {
    //        EchoMessage memory parsedMessage = EchoMessage({
    //            payloadID: uint8(1),
    //            id: message.id,
    //            evmSender: message.evmSender,
    //            evmReceiver: message.evmReceiver,
    //            evmTokenAddress: message.evmTokenAddress,
    //            evmTokenId: message.evmTokenId,
    //            solSender: message.solSender,
    //            solReceiver: message.solReceiver,
    //            solSenderTokenMint: message.solSenderTokenMint
    //        });
    //
    //        bytes memory encodedMessage = _encodeMessage(parsedMessage);
    //
    //        // Send the Echo message by calling publishMessage on the
    //        // Wormhole core contract and paying the Wormhole protocol fee.
    //        messageSequence = wormhole.publishMessage{value: wormholeFee}(
    //            0, // batchID
    //            encodedMessage,
    //            _state.wormholeFinality
    //        );
    //    }
    //
    //    /**
    //     * @notice Consumes arbitrary Echo messages sent by registered emitters
    //     * @dev The arbitrary message is verified by the Wormhole core endpoint
    //     * `verifyVM`.
    //     * Reverts if:
    //     * - `encodedMessage` is not attested by the Wormhole network
    //     * - `encodedMessage` was sent by an unregistered emitter
    //     * - `encodedMessage` was consumed already
    //     * @param encodedMessage verified Wormhole message containing arbitrary
    //     * @return parsedMessage EchoMessage The parsed message from Wormhole
    //     */
    //    function receiveMessage(
    //        bytes memory encodedMessage
    //    ) internal returns (EchoMessage memory parsedMessage) {
    //        // call the Wormhole core contract to parse and verify the encodedMessage
    //        (IWormhole.VM memory wormholeMessage, bool valid, string memory reason) = wormholeContract()
    //            .parseAndVerifyVM(encodedMessage);
    //
    //        if (!valid) {
    //            // TODO Add reason?
    //            revert FailedParsingAndVerifyingVm();
    //        }
    //
    //        if (!_verifyEmitter(wormholeMessage)) {
    //            revert InvalidEmitter();
    //        }
    //
    //        parsedMessage = _decodeMessage(wormholeMessage.payload);
    //
    //        if (isMessageConsumed(wormholeMessage.hash)) {
    //            revert MessageAlreadyConsumed();
    //        }
    //        _consumeMessage(wormholeMessage.hash);
    //    }

    modifier hasEnoughWormholeFees() {
        IWormhole wormhole = this.wormholeContract();
        uint256 wormholeFee = wormhole.messageFee();

        if (msg.value != wormholeFee) {
            revert NotEnoughWormholeFees();
        }
        _;
    }
}
