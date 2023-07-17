// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import './BaseTest.t.sol';
import './mock/Mocked721.t.sol';
import 'forge-std/Test.sol';

contract FeesTest is BaseTest {
    function testRevertsWithoutFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);

        vm.prank(account1);
        // 0 ether
        vm.expectRevert(InvalidPayment.selector);
        echo.executeTrade(v, r, s, trade);

        // Not enough ether
        vm.prank(account1);
        vm.expectRevert(InvalidPayment.selector);
        echo.executeTrade{value: 0.004 ether}(v, r, s, trade);
    }
    function testSucceedsWithFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);

        vm.prank(account1);
        echo.executeTrade{value: 0.005 ether}(v, r, s, trade);
        assertEq(address(echo).balance, 0.005 ether);
        assertEq(account1.balance, 100 ether - 0.005 ether);
    }
}
