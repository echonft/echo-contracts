// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract WrongAssetsTest is BaseTest {
    function testCannotSwapEmptyCreatorAssets() public {
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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testCannotSwapEmptyCounterpartyAssets() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);

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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testCannotSwapEmptyAssets() public {
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
        vm.expectRevert(InvalidAssets.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testCannotTradeLongerCreatorIds() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
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
        vm.expectRevert(LengthMismatch.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(apes.ownerOf(2), account1);
        assertEq(birds.ownerOf(1), account2);
    }

    function testCannotTradeLongerCreatorCollections() public {
        creator721Collections.push(apeAddress);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
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
        vm.expectRevert(LengthMismatch.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
    }

    function testCannotTradeLongerCounterpartyIds() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
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
        vm.expectRevert(LengthMismatch.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
        assertEq(birds.ownerOf(2), account2);
    }

    function testCannotTradeLongerCounterpartyCollections() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
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
        vm.expectRevert(LengthMismatch.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
    }

    function testCannotTradeSameCreatorAssets() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
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
        vm.expectRevert("WRONG_FROM");
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
    }

    function testCannotTradeSameCounterpartyAssets() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);
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
        vm.expectRevert("WRONG_FROM");
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
    }
}
