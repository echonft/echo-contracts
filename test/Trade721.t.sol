// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract Trade721Test is BaseTest {
    function testCannotSwapEmptyCreatorAssets() public {
        counterparty721Assets.push(bird1);
        counterparty721Assets.push(bird2);

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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, trade);
    }

    function testCannotSwapEmptyCounterpartyAssets() public {
        creator721Assets.push(ape1);

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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, trade);
    }

    function testCannotSwapEmptyAssets() public {
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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, trade);
    }

    /// @dev Swap: 1 ape for 2 birds
    function testSwapOneForTwo() public {
        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);
        counterparty721Assets.push(bird2);

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
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test", account1);
        echo.executeTrade(v, r, s, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(birds.ownerOf(1), account1);
        assertEq(birds.ownerOf(2), account1);
    }

    /// @dev Swap: 2 apes for 1 bird
    function testSwapTwoForOne() public {
        creator721Assets.push(ape1);
        creator721Assets.push(ape2);
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
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test", account1);
        echo.executeTrade(v, r, s, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(apes.ownerOf(2), account2);
        assertEq(birds.ownerOf(1), account1);
    }

    /// @dev Swap: 2 apes for 2 birds
    function testSwapTwoForTwo() public {
        creator721Assets.push(ape1);
        creator721Assets.push(ape2);
        counterparty721Assets.push(bird1);
        counterparty721Assets.push(bird2);

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
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test", account1);
        echo.executeTrade(v, r, s, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(apes.ownerOf(2), account2);
        assertEq(birds.ownerOf(1), account1);
        assertEq(birds.ownerOf(2), account1);
    }

    function testCannotReuseTradeId() public {
        // Execute initial swap
        testSwapTwoForTwo();

        // Second swap with same Id
        counterparty721Assets.push(ape1);
        counterparty721Assets.push(ape2);
        creator721Assets.push(bird1);
        creator721Assets.push(bird2);

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
        vm.expectRevert(TradeAlreadyExist.selector);
        echo.executeTrade(v, r, s, trade);
    }
}
