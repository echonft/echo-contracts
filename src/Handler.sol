// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct ERC721Asset {
    address collection;
    uint64 id;
}

abstract contract Handler {
    function _transferERC721(ERC721Asset memory token, address from, address to) internal {
        IERC721 collection = IERC721(token.collection);
        collection.safeTransferFrom(from, to, token.id);
    }

    function _transferTokens(ERC721Asset[] memory tokens, address from, address to) internal {
        for (uint256 i = 0; i < tokens.length; ++i) {
            _transferERC721(tokens[i], from, to);
        }
    }
}
