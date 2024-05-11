// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
import "forge-std/Test.sol";

contract BankerTest is BaseTest {
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

    function testCannotWithdrawIfNotOwner() public {
        _setFees();
        _executeSingleAssetOffer();

        vm.prank(account1);
        vm.expectRevert("UNAUTHORIZED");
        echo.withdraw(account1);
    }

    function testCanWithdrawToSelfIfOwner() public {
        _setFees();
        _executeSingleAssetOffer();

        assertEq(address(echo).balance, echo.tradingFee() * 2);
        vm.prank(owner);
        echo.withdraw(owner);
        assertEq(owner.balance, echo.tradingFee() + echo.tradingFee());
        assertEq(address(echo).balance, 0);
    }

    function testCanWithdrawToOtherAccountIfOwner() public {
        uint256 initialBalance = account3.balance;
        _setFees();
        _executeSingleAssetOffer();

        vm.prank(owner);
        echo.withdraw(account3);
        assertEq(account3.balance, initialBalance + echo.tradingFee() * 2);
        assertEq(address(echo).balance, 0);
    }

    function testCannotWithdrawToContractIfOwner() public {
        _setFees();
        _executeSingleAssetOffer();

        vm.prank(owner);
        vm.expectRevert(WithdrawFailed.selector);
        echo.withdraw(address(echo));
        assertEq(address(echo).balance, echo.tradingFee() * 2);
    }
}
