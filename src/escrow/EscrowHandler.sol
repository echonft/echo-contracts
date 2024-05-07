// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/tokens/ERC721.sol";
import "contracts/types/OfferItems.sol";

abstract contract EscrowHandler is ERC721TokenReceiver {
    function _transferERC721(address collectionAddress, uint256 id, address from, address to) internal {
        ERC721 collection = ERC721(collectionAddress);
        collection.safeTransferFrom(from, to, id);
    }

    // @dev function to transfer items from an offer type
    function _transferOfferItems(OfferItems memory offerItems, address from, address to) internal {
        uint256 length = offerItems.items.length;
        for (uint256 i = 0; i < length;) {
            _transferERC721(offerItems.items[i].tokenAddress, offerItems.items[i].tokenId, from, to);
            unchecked {
                i++;
            }
        }
    }
}
