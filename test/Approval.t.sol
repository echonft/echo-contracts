// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract ApprovalTest is BaseTest {
    // Creator has not approved its apes
    function testCannotExecuteTradeIfCreatorDidNotApprove() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape3Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account3,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);

        vm.prank(account3);
        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        echo.executeTrade(v, r, s, trade);
    }

    /// Counterparty has not approved its birds
    function testCannotExecuteTradeIfCounterpartyDidNotApprove() public {
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

        vm.startPrank(account2);
        birds.setApprovalForAll(address(echo), false);
        vm.stopPrank();

        vm.prank(account1);
        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        echo.executeTrade(v, r, s, trade);
    }

    /// Succeeds when both creator and counterparty have approved their assets
    function testSucceedsWhenApproved() public {
        // Assets are in original state
        assertEq(apes.ownerOf(1), account1);
        assertEq(birds.ownerOf(1), account2);

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

        vm.prank(account1);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.executeTrade(v, r, s, trade);

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(birds.ownerOf(1), account1);
    }
}
