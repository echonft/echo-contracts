// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTestBlast.t.sol";

contract AdminBlastTest is BaseTestBlast {
    function testCannotClaimGasIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echoBlast.claimGas();
    }

    // TODO Should be able to test that properly
    function testCanClaimGasIfNotOwner() public {
        vm.prank(owner);
        vm.expectRevert(bytes("must withdraw non-zero amount"));
        echoBlast.claimGas();
    }
}
