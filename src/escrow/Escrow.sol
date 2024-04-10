// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/escrow/EscrowData.sol";
import "contracts/escrow/EscrowHandler.sol";
import "contracts/escrow/EscrowState.sol";

abstract contract Escrow is EscrowState, EscrowHandler {
    function _depositForReceiver(Offer calldata offer) internal {
        _transferERC721(offer.receiver721Asset.collection, offer.receiver721Asset.id, offer.receiver, address(this));
    }
}
