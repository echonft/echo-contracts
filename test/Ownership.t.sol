// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract OwnershipTest is BaseTest {
    /// Sender is not creator
    function testCannotExecuteTradeIfNotCreator() public {
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
        // Counterparty
        vm.prank(account2);
        vm.expectRevert(InvalidCreator.selector);
        echo.executeTrade(v, r, s, trade);

        // Random account
        vm.prank(account3);
        vm.expectRevert(InvalidCreator.selector);
        echo.executeTrade(v, r, s, trade);
    }

    // Creator
    function testCannotExecuteTradeIfCreatorNotOwner() public {
        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);
        Trade memory trade = Trade({
            id: "test",
            creator: account3,
            counterparty: account2,
            expiresAt: in6hours,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);

        vm.prank(account3);
        vm.expectRevert(bytes("ERC721: transfer from incorrect owner"));
        echo.executeTrade(v, r, s, trade);
    }

    // TODO Should be the same error message as the other?
    function testCannotExecuteTradeIfCounterpartyNotOwner() public {
        creator721Assets.push(ape1);
        counterparty721Assets.push(bird3);
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
        vm.expectRevert(bytes("ERC721: caller is not token owner or approved"));
        echo.executeTrade(v, r, s, trade);
    }
}
