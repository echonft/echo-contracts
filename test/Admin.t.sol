// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract AdminTest is BaseTest {
    function testCannotPauseIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.setPaused(true);

        assertEq(echo.paused(), false);
    }

    function testCanPauseIfOwner() public {
        vm.prank(owner);
        echo.setPaused(true);
        assertEq(echo.paused(), true);

        vm.prank(owner);
        echo.setPaused(false);
        assertEq(echo.paused(), false);
    }

    function testCannotPauseCreationIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.setCreationPaused(true);

        assertEq(echo.creationPaused(), false);
    }

    function testCanPauseCreationIfOwner() public {
        vm.prank(owner);
        echo.setCreationPaused(true);
        assertEq(echo.creationPaused(), true);

        vm.prank(owner);
        echo.setCreationPaused(false);
        assertEq(echo.creationPaused(), false);
    }
}
