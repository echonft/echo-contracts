// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "src/Handler.sol";

contract MockedHandler is Handler {
    function transferTokens(address[] memory collections, uint256[] memory ids, address from, address to) external {
        _transferTokens(collections, ids, from, to);
    }
}
