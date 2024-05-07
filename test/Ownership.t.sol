// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
import "forge-std/Test.sol";

contract OwnershipTest is BaseTest {
//    // Sender is not creator
//    function testCannotExecuteTradeIfNotCreator() public {
//        creator721Collections.push(apeAddress);
//        creator721Ids.push(ape1Id);
//        counterparty721Collections.push(birdAddress);
//        counterparty721Ids.push(bird1Id);
//
//        Trade memory trade = Trade({
//            id: "test",
//            creator: account1,
//            counterparty: account2,
//            expiresAt: in6hours,
//            creatorCollections: creator721Collections,
//            creatorIds: creator721Ids,
//            counterpartyCollections: counterparty721Collections,
//            counterpartyIds: counterparty721Ids
//        });
//
//        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature) =
//            _prepareSignature(trade, account2PrivateKey, signerPrivateKey);
//        // Counterparty
//        vm.prank(account2);
//        vm.expectRevert(InvalidCreator.selector);
//        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
//
//        // Random account
//        vm.prank(account3);
//        vm.expectRevert(InvalidCreator.selector);
//        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
//    }
//
//    // Creator is not owner
//    function testCannotExecuteTradeIfCreatorNotOwner() public {
//        creator721Collections.push(apeAddress);
//        creator721Ids.push(ape1Id);
//        counterparty721Collections.push(birdAddress);
//        counterparty721Ids.push(bird1Id);
//
//        Trade memory trade = Trade({
//            id: "test",
//            creator: account3,
//            counterparty: account2,
//            expiresAt: in6hours,
//            creatorCollections: creator721Collections,
//            creatorIds: creator721Ids,
//            counterpartyCollections: counterparty721Collections,
//            counterpartyIds: counterparty721Ids
//        });
//
//        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature) =
//            _prepareSignature(trade, account2PrivateKey, signerPrivateKey);
//        vm.prank(account3);
//        vm.expectRevert(bytes("WRONG_FROM"));
//        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
//    }
//
//    // TODO Should be the same error message as the other?
//    // Counterparty is not owner
//    function testCannotExecuteTradeIfCounterpartyNotOwner() public {
//        creator721Collections.push(apeAddress);
//        creator721Ids.push(ape1Id);
//        counterparty721Collections.push(birdAddress);
//        counterparty721Ids.push(bird3Id);
//        Trade memory trade = Trade({
//            id: "test",
//            creator: account1,
//            counterparty: account2,
//            expiresAt: in6hours,
//            creatorCollections: creator721Collections,
//            creatorIds: creator721Ids,
//            counterpartyCollections: counterparty721Collections,
//            counterpartyIds: counterparty721Ids
//        });
//
//        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature) =
//            _prepareSignature(trade, account2PrivateKey, signerPrivateKey);
//        vm.prank(account1);
//        vm.expectRevert(bytes("WRONG_FROM"));
//        echo.executeTrade(vSigner, rSigner, sSigner, signature, trade);
//    }
}
