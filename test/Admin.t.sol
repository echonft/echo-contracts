// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract AdminTest is BaseTest {
    function testCannotChangeFeesIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.setFees(0 ether);
    }

    function testCanChangeFeesIfOwner() public {
        vm.prank(owner);
        echo.setFees(0.005 ether);
        assertEq(echo.tradingFee(), 0.005 ether);
    }

    function testCannotPauseIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.setPaused(true);

        vm.expectRevert("UNAUTHORIZED");
        echo.setPaused(false);
    }

    function testCanPauseIfOwner() public {
        vm.prank(owner);
        echo.setPaused(true);
        assertEq(echo.paused(), true);

        vm.prank(owner);
        echo.setPaused(false);
        assertEq(echo.paused(), false);
    }

    function testCannotWithdrawIfNotOwner() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        _executeMockTrade("test", account1, account2, 0.005 ether);

        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.withdraw(account1);
    }

    function testCanWithdrawToSelfIfOwner() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        _executeMockTrade("test", account1, account2, 0.005 ether);

        assertEq(address(echo).balance, 0.005 ether);
        vm.prank(owner);
        echo.withdraw(owner);
        assertEq(owner.balance, 0.005 ether);
        assertEq(address(echo).balance, 0);
    }

    function testCanWithdrawToOtherAccountIfOwner() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        _executeMockTrade("test", account1, account2, 0.005 ether);

        vm.prank(owner);
        echo.withdraw(account3);
        assertEq(account3.balance, 100 ether + 0.005 ether);
        assertEq(address(echo).balance, 0);
    }

    function testCannotWithdrawToContractIfOwner() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        _executeMockTrade("test", account1, account2, 0.005 ether);

        vm.prank(owner);
        vm.expectRevert(WithdrawFailed.selector);
        echo.withdraw(address(echo));
        assertEq(account3.balance, 100 ether);
        assertEq(address(echo).balance, 0.005 ether);
    }

    function testCannotChangeSignerIfNotOwner() public {
        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.setSigner(address(0));
    }

    function testCanChangeSignerIfOwner() public {
        vm.prank(owner);
        echo.setSigner(address(0));
        assertEq(echo.signer(), address(0));
    }
}
