// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/escrow/EscrowHandler.sol";
import "contracts/types/OfferItems.sol";

abstract contract Escrow is EscrowHandler {
    function _deposit(OfferItems calldata offerItems, address from) internal {
        _transferOfferItems(offerItems, from, address(this));
    }

    function _withdraw(OfferItems calldata offerItems, address to) internal {
        _transferOfferItems(offerItems, address(this), to);
    }
}
