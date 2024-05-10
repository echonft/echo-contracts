// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./EscrowHandler.sol";
import "../types/OfferItems.sol";

abstract contract Escrow is EscrowHandler {
    function _deposit(OfferItems memory offerItems, address from) internal {
        _transferOfferItems(offerItems, from, address(this));
    }

    function _withdraw(OfferItems memory offerItems, address to) internal {
        _transferOfferItems(offerItems, address(this), to);
    }
}
