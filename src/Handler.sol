// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/tokens/ERC721.sol";

error LengthMismatch();

abstract contract Handler {
    function _transferERC721(address collectionAddress, uint256 id, address from, address to) internal {
        ERC721 collection = ERC721(collectionAddress);
        collection.safeTransferFrom(from, to, id);
    }

    function _transferTokens(address[] memory collections, uint256[] memory ids, address from, address to) internal {
        if (collections.length != ids.length) revert LengthMismatch();
        for (uint256 i = 0; i < collections.length; ++i) {
            _transferERC721(collections[i], ids[i], from, to);
        }
    }
}
