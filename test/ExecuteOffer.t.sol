// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/Offer.sol";

contract ExecuteOfferTest is BaseTest {
    function testCannotExecuteNonExistentOffer() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape2Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird2Id;
        uint256[] memory receiverTokenAmounts = new uint256[](1);
        receiverTokenAmounts[0] = 0;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory invalidOffer =
            generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        bytes32 offerId = generateOfferId(invalidOffer);

        vm.prank(account1);
        vm.expectRevert(InvalidSender.selector);
        echo.executeOffer(offerId);
    }

    function testCannotExecuteOfferIfNotAccepted() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        vm.expectRevert("WRONG_FROM");
        echo.executeOffer(offerId);
    }

    function testCanExecuteOfferSingleAsset() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        echo.executeOffer(offerId);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is executed, it's also deleted
        assertEq(sender, address(0));

        // validate that the sender items are swapped
        assertOfferItemsOwnership(offer.senderItems.items, offer.receiver);
        // validate that the receiver items are swapped
        assertOfferItemsOwnership(offer.receiverItems.items, offer.sender);
    }

    function testCanExecuteOfferMultipleAssets() public {
        Offer memory offer = _createAndAcceptMultipleAssetsOffer();

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        echo.executeOffer(offerId);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is executed, it's also deleted
        assertEq(sender, address(0));

        // validate that the sender items are swapped
        assertOfferItemsOwnership(offer.senderItems.items, offer.receiver);
        // validate that the receiver items are swapped
        assertOfferItemsOwnership(offer.receiverItems.items, offer.sender);
    }

    function testCanExecuteOfferMultiTokens() public {
        Offer memory offer = _executeMultiTokensOffer();
        bytes32 offerId = generateOfferId(offer);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is executed, it's also deleted
        assertEq(sender, address(0));

        // validate that the sender items are swapped
        assertOfferItemsOwnership(offer.senderItems.items, offer.receiver);
        // validate that the receiver items are swapped
        assertOfferItemsOwnership(offer.receiverItems.items, offer.sender);
    }
}
