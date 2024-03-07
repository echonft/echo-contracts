// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract ExpirationTest is BaseTest {
    function testExpiresAtCurrentBlock() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

        uint256 expired = block.timestamp;
        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: expired,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testExpiresBeforeCurrentBlock() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

        uint256 expired = block.timestamp - 1;
        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: expired,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }
}
