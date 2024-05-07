// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/wormhole/IWormhole.sol";
import "contracts/wormhole/WormholeError.sol";
import "solmate/auth/Owned.sol";

struct State {
    // address of the Wormhole contract on this chain
    address wormhole;
    // @dev Need to store the chain ID as it might differ from the real id
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
    // verified message hash to boolean
    mapping(bytes32 => bool) consumedMessages;
}

abstract contract WormholeState is Owned {
    State internal _state;

    function isMessageConsumed(bytes32 hash) external view returns (bool) {
        return _state.consumedMessages[hash];
    }

    function wormholeContract() external view returns (IWormhole) {
        return IWormhole(_state.wormhole);
    }

    function chainId() external view returns (uint16) {
        return _state.chainId;
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

        _state.registeredEmitters[emitterChainId] = emitterAddress;
    }

    function _consumeMessage(bytes32 hash) internal {
        _state.consumedMessages[hash] = true;
    }

    function _verifyEmitter(IWormhole.VM memory vm) internal view returns (bool) {
        return _state.registeredEmitters[vm.emitterChainId] == vm.emitterAddress;
    }
}
