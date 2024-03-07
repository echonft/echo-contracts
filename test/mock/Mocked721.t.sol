// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "solmate/tokens/ERC721.sol";
import "solady/src/utils/LibString.sol";

abstract contract BaseERC721 is ERC721 {
    // Exclude from coverage report
    function test() public virtual {}

    // The tokenId of the next token to be minted.
    uint256 internal _currentIndex;
    string private baseURI;

    function safeMint(address to, uint256 tokenId) public {
        _safeMint(to, tokenId);
    }

    function publicMint(uint256 quantity) external {
        for (uint256 i = 0; i < quantity; i++) {
            _safeMint(msg.sender, _currentIndex, "");
            _currentIndex++;
        }
    }

    function setBaseURI(string memory uri) public {
        baseURI = uri;
    }

    function _baseURI() internal view returns (string memory) {
        return baseURI;
    }
}

contract Mocked721 is BaseERC721 {
    // Exclude from coverage report
    function test() public override {}

    using LibString for uint256;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        string memory uri = _baseURI();
        return bytes(uri).length > 0 ? string(abi.encodePacked(uri, id.toString())) : "";
    }
}

contract Mocked721WithSuffix is BaseERC721 {
    // Exclude from coverage report
    function test() public override {}

    using LibString for uint256;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function tokenURI(uint256 id) public view override returns (string memory) {
        string memory uri = _baseURI();
        return bytes(uri).length > 0 ? string(abi.encodePacked(uri, id.toString(), ".json")) : "";
    }
}
