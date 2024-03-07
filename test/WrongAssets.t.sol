// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract WrongAssetsTest is BaseTest {
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

        vm.expectRevert(InvalidAssets.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

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

        vm.expectRevert(InvalidAssets.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

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

        vm.expectRevert(InvalidAssets.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

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

        vm.expectRevert(InvalidAssets.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

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

        vm.expectRevert("WRONG_FROM");
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

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

        vm.expectRevert("WRONG_FROM");
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

        // Assets are not swapped
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);
    }
}
