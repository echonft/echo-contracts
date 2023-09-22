// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "solmate/tokens/ERC721.sol";

contract Mocked721 is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "test";
    }

    // add this to be excluded from coverage report
    function test() public {}
}
