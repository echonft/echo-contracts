// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract OwnershipTest is BaseTest {
    // Sender is not creator
    function testCannotExecuteTradeIfNotCreator() public {
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

        // Counterparty
        vm.expectRevert(InvalidCreator.selector);
        _executeTrade(trade, account2, account2PrivateKey, signerPrivateKey, echo.tradingFee());

        // Random account
        vm.expectRevert(InvalidCreator.selector);
        _executeTrade(trade, account3, account2PrivateKey, signerPrivateKey, echo.tradingFee());
    }

    // Creator is not owner
    function testCannotExecuteTradeIfCreatorNotOwner() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
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
        vm.expectRevert(bytes("WRONG_FROM"));
        _executeTrade(trade, account3, account2PrivateKey, signerPrivateKey, echo.tradingFee());
    }

    // TODO Should be the same error message as the other?
    // Counterparty is not owner
    function testCannotExecuteTradeIfCounterpartyNotOwner() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird3Id);
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

        vm.expectRevert(bytes("WRONG_FROM"));
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, echo.tradingFee());
    }
}
