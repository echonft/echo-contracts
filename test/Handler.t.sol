// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/Handler.sol";
import "./mock/Mocked721.t.sol";

contract HandlerTest is Test, Handler {
    Mocked721 apes;
    Mocked721 birds;

    address constant account1 = address(1337);
    address constant account2 = address(1339);

    address apeAddress;
    uint256 ape1Id;
    uint256 ape2Id;
    address birdAddress;
    uint256 bird1Id;
    uint256 bird2Id;
    address[] collections;
    uint256[] ids;

    function setUp() public {
        apes = new Mocked721("Apes", "APE");
        birds = new Mocked721("Birds", "BIRD");

        apeAddress = address(apes);
        ape1Id = 1;
        ape2Id = 2;
        birdAddress = address(birds);
        bird1Id = 1;
        bird2Id = 2;
    }

    function testIdsLonger() public {
        collections.push(apeAddress);
        ids.push(ape1Id);
        ids.push(ape2Id);

        vm.expectRevert(LengthMismatch.selector);
        _transferTokens(collections, ids, account1, account2);
    }

    function testCollectionsLonger() public {
        collections.push(apeAddress);
        collections.push(apeAddress);
        ids.push(ape1Id);

        vm.expectRevert(LengthMismatch.selector);
        _transferTokens(collections, ids, account1, account2);
    }
}
