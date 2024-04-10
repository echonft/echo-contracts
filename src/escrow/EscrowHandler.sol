// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/Handler.sol";
import "forge-std/interfaces/IERC721.sol";

//
abstract contract EscrowHandler is Handler, IERC721TokenReceiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        pure
        returns (bytes4)
    {
        return this.onERC721Received.selector;
    }
}
