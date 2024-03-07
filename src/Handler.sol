// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/interfaces/IERC721.sol";

error LengthMismatch();

abstract contract Handler {
    function _transferERC721(address collectionAddress, uint256 id, address from, address to) internal {
        IERC721 collection = IERC721(collectionAddress);
        collection.safeTransferFrom(from, to, id);
    }

    function _transferTokens(address[] memory collections, uint256[] memory ids, address from, address to) internal {
        if (collections.length != ids.length) revert LengthMismatch();
        uint256 length = collections.length;
        for (uint256 i = 0; i < length;) {
            _transferERC721(collections[i], ids[i], from, to);
            unchecked {
                i++;
            }
        }
    }
}
