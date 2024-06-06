// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract RedeemOfferTest is BaseTest {
    function testSenderCannotRedeemOpenOfferTwice() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the sender items are escrowed
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is redeemed, it's also deleted
        assertEq(sender, address(0));

        vm.prank(account1);
        vm.expectRevert(ItemsOutOfEscrow.selector);
        echo.redeemOffer(offerId);
    }

    function testSenderCannotRedeemAcceptedOfferTwice() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the sender items are escrowed
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because receiver has not redeemed
        assertEq(sender, offer.sender);

        vm.prank(account1);
        // @dev withdraw fails
        vm.expectRevert(ItemsOutOfEscrow.selector);
        echo.redeemOffer(offerId);
    }

    function testReceiverCannotRedeemAcceptedOfferTwice() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the receiver items are escrowed
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account2);
        echo.redeemOffer(offerId);

        // validate that the receiver items are redemeed
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);

        (, address receiver,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because sender has not redeemed
        assertEq(receiver, offer.receiver);

        vm.prank(account2);
        // @dev withdraw fails
        vm.expectRevert(ItemsOutOfEscrow.selector);
        echo.redeemOffer(offerId);
    }

    function testSenderCanRedeemExpiredOpenOffer() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the sender items are escrowed
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is redeemed, it's also deleted
        assertEq(sender, address(0));
    }

    function testSenderCanRedeemExpiredAcceptedOffer() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the sender items are escrowed
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because receiver has not redeemed
        assertEq(sender, offer.sender);
    }

    function testReceiverCanRedeemExpiredAcceptedOffer() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the receiver items are escrowed
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account2);
        echo.redeemOffer(offerId);

        // validate that the receiver items are redemeed
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);

        (, address receiver,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because sender has not redeemed
        assertEq(receiver, offer.receiver);
    }

    function testExpiredAcceptedOfferIsDeletedWhenFullyRedeemedReceiverFirst() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        // validate that the receiver items are escrowed
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));

        vm.warp(in6hours);
        vm.prank(account2);
        echo.redeemOffer(offerId);

        // validate that the receiver items are redemeed
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);

        (, address receiver,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because sender has not redeemed
        assertEq(receiver, offer.receiver);

        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (address sender,,,,,) = echo.offers(offerId);
        // @dev When the offer is redeemed, it's also deleted
        assertEq(sender, address(0));
    }

    function testExpiredAcceptedOfferIsDeletedWhenFullyRedeemedSenderFirst() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        // validate that the sender items are redemeed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);

        (, address receiver,,,,) = echo.offers(offerId);

        // @dev Offer is still existing because sender has not redeemed
        assertEq(receiver, offer.receiver);

        // validate that the receiver items are escrowed
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));

        vm.prank(account2);
        echo.redeemOffer(offerId);

        // validate that the receiver items are redemeed
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);

        (address sender,,,,,) = echo.offers(offerId);
        // @dev When the offer is redeemed, it's also deleted
        assertEq(sender, address(0));
    }
}
