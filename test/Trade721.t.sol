// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract Trade721Test is BaseTest {
    // @dev Swap: 1 ape for 2 birds
    function testSwapOneForTwo() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird2Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(birds.ownerOf(1), account1);
        assertEq(birds.ownerOf(2), account1);
    }

    // @dev Swap: 2 apes for 1 bird
    function testSwapTwoForOne() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape2Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(apes.ownerOf(2), account2);
        assertEq(birds.ownerOf(1), account1);
    }

    // @dev Swap: 2 apes for 2 birds
    function testSwapTwoForTwo() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape2Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird2Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

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
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape2Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird2Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeAlreadyExist.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }
}
