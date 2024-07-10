// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract PausedTest is BaseTest {
    function testCannotCreateOfferIfPaused() public {
        _setPaused();

        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;
        uint256[] memory receiverTokenAmounts = new uint256[](1);
        receiverTokenAmounts[0] = 0;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(Paused.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfCreationPaused() public {
        _setCreationPaused();

        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;
        uint256[] memory receiverTokenAmounts = new uint256[](1);
        receiverTokenAmounts[0] = 0;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(CreationPaused.selector);
        echo.createOffer(offer);
    }

    function testCanAcceptOfferIfCreationPaused() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setCreationPaused();

        vm.prank(account2);
        echo.acceptOffer(offerId);

        // validate that the sender items are in escrow
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));
        // validate that the receiver items are in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));
    }

    function testCanExecuteOfferIfCreationPaused() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setCreationPaused();

        vm.prank(account1);
        echo.executeOffer(offerId);

        // validate that the sender items are swapped
        assertOfferItemsOwnership(offer.senderItems.items, offer.receiver);
        // validate that the receiver items are swapped
        assertOfferItemsOwnership(offer.receiverItems.items, offer.sender);
    }

    function testCanRedeemExpiredOfferIfCreationPaused() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setCreationPaused();

        vm.warp(in6hours);
        vm.prank(account1);
        echo.redeemOffer(offerId);

        vm.prank(account2);
        echo.redeemOffer(offerId);

        // validate that the sender items are redeemed
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);
        // validate that the receiver items are redeemed
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }

    function testCannotAcceptOfferIfPaused() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setPaused();

        vm.prank(account2);
        vm.expectRevert(Paused.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotCancelOfferIfPaused() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setPaused();

        vm.prank(account1);
        vm.expectRevert(Paused.selector);
        echo.cancelOffer(offerId);
    }

    function testCannotExecuteOfferIfPaused() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setPaused();

        vm.prank(account1);
        vm.expectRevert(Paused.selector);
        echo.executeOffer(offerId);
    }

    function testCannotRedeemOfferIfPaused() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);
        _setPaused();

        vm.prank(account1);
        vm.expectRevert(Paused.selector);
        echo.redeemOffer(offerId);
    }
}
