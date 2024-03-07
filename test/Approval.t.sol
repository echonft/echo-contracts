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

        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        _executeTrade(trade, account3, account2PrivateKey, signerPrivateKey, echo.tradingFee());
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

        vm.startPrank(account2);
        birds.setApprovalForAll(address(echo), false);
        vm.stopPrank();

        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());
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

        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());

        // Assets are now swapped
        assertEq(apes.ownerOf(1), account2);
        assertEq(birds.ownerOf(1), account1);
    }
}
