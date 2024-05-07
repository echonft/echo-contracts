// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
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
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature) =
            _prepareSignature(trade, account2PrivateKey, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
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
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature) =
            _prepareSignature(trade, account2PrivateKey, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(TradeHasExpired.selector);
        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
    }
}
