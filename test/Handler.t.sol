// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/Handler.sol";
import "./BaseTest.t.sol";

contract HandlerTest is BaseTest, Handler {
    function testIdsLonger() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        creator721Ids.push(ape2Id);

        vm.expectRevert(LengthMismatch.selector);
        _transferTokens(creator721Collections, creator721Ids, account1, account2);
    }

    function testCollectionsLonger() public {
        creator721Collections.push(apeAddress);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape2Id);

        vm.expectRevert(LengthMismatch.selector);
        _transferTokens(creator721Collections, creator721Ids, account1, account2);
    }
}
