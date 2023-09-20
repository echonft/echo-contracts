// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract ExpirationTest is BaseTest {
    function testExpiresAtCurrentBlock() public {
        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);
        uint256 expired = block.timestamp;
        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: expired,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(v, r, s, trade);
    }

    function testExpiresBeforeCurrentBlock() public {
        creator721Assets.push(ape1);
        counterparty721Assets.push(bird1);
        uint256 expired = block.timestamp - 1;
        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: expired,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(v, r, s, trade);
    }
}
