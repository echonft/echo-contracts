// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct ERC721Asset {
    address collection;
    uint64 id;
}

abstract contract Handler is IERC721Receiver {

    function _transferERC721(
        ERC721Asset memory token,
        address from,
        address to
    ) internal {
        IERC721 collection = IERC721(token.collection);
        collection.safeTransferFrom(from, to, token.id);
    }

    function _transferTokens(
        ERC721Asset[] memory tokens,
        address from,
        address to
    ) internal {
        // TODO Maybe multicall?
        for (uint256 i = 0; i < tokens.length; ++i) {
            _transferERC721(tokens[i], from, to);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }


    function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    returns (bool)
    {
        return interfaceId == type(IERC721).interfaceId;
    }
}