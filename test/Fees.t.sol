// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract FeesTest is BaseTest {
    function testRevertsWithoutFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

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
        vm.expectRevert(InvalidPayment.selector);
        // 0 ether
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);

        vm.prank(account1);
        vm.expectRevert(InvalidPayment.selector);
        // Not enough ether
        echo.executeTrade{value: 0.004 ether}(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testSucceedsWithFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

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
        echo.executeTrade{value: 0.005 ether}(v, r, s, vSigner, rSigner, sSigner, trade);
        assertEq(address(echo).balance, 0.005 ether);
        assertEq(account1.balance, 100 ether - 0.005 ether);
    }
}
