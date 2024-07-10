// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/tokens/ERC721.sol";
import "../types/OfferItems.sol";
import {SafeTransferLib} from "solady/src/utils/SafeTransferLib.sol";

abstract contract EscrowHandler is ERC721TokenReceiver {
    function _transferERC721(address collectionAddress, uint256 id, address from, address to) internal {
        ERC721 collection = ERC721(collectionAddress);
        collection.safeTransferFrom(from, to, id);
    }

    function _transferERC20(address tokenAddress, uint256 amount, address from, address to) internal {
        if (address(this) == from) {
            SafeTransferLib.safeTransfer(tokenAddress, to, amount);
        } else {
            SafeTransferLib.safeTransferFrom(tokenAddress, from, to, amount);
        }
    }

    // @dev function to transfer items from an offer type. We check for the amount to distinguish ERC20
    function _transferOfferItems(OfferItems memory offerItems, address from, address to) internal {
        uint256 length = offerItems.items.length;
        for (uint256 i = 0; i < length;) {
            OfferItem memory item = offerItems.items[i];
            if (item.amount >= 1) {
                _transferERC20(item.tokenAddress, item.amount, from, to);
            } else {
                _transferERC721(item.tokenAddress, item.tokenId, from, to);
            }
            unchecked {
                i++;
            }
        }
    }
}
