// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract EdgeCasesTest is BaseTest {
    function testCanCreateGhostOffer() public {
        // Create an accept an offer
        Offer memory initialOffer = _createAndAcceptSingleAssetOffer();
        bytes32 initialOfferId = generateOfferId(initialOffer);

        assertEq(birds.ownerOf(bird1Id), address(echo));
        // Account 2 redeems offer
        vm.warp(in6hours);
        vm.prank(account2);
        echo.redeemOffer(initialOfferId);
        vm.stopPrank();
        assertEq(birds.ownerOf(bird1Id), account2);

        // Account 2 creates a new offer with the same NFT
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = birdAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = bird1Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;
        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = apeAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = ape2Id;
        uint256[] memory receiverTokenAmounts = new uint256[](1);
        receiverTokenAmounts[0] = 0;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory newOffer = generateOffer(
            account2, senderItems, account1, receiverItems, block.timestamp + (60 * 60 * 6), OfferState.OPEN
        );

        bytes32 newOfferId = generateOfferId(newOffer);
        vm.prank(account2);
        echo.createOffer(newOffer);
        vm.stopPrank();

        // Account 1 redeems offer
        vm.prank(account1);
        echo.redeemOffer(initialOfferId);
        vm.stopPrank();
        // Offer is deleted properly
        (address senderInitialOffer,,,,,) = echo.offers(initialOfferId);
        assertEq(senderInitialOffer, address(0));

        // Account 1 accept new offer
        vm.prank(account1);
        echo.acceptOffer(newOfferId);
        vm.stopPrank();

        // Account 2 tries to redeem initial offer again
        vm.prank(account2);
        echo.redeemOffer(initialOfferId);
        vm.stopPrank();

        // Offer doesn't exist anymore
        (,,,, uint256 newExpiration,) = echo.offers(initialOfferId);
        assertEq(0, newExpiration);

        // Account 2 now executes new offer
        vm.prank(account2);
        echo.executeOffer(newOfferId);

        // New offer doesn't exist anymore
        (,,,, uint256 latestExpiration,) = echo.offers(newOfferId);
        assertEq(0, latestExpiration);
    }
}
