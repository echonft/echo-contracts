// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/Offer.sol";

contract CancelOfferTest is BaseTest {
    function testCannotCancelNonExistentOffer() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape2Id;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird2Id;

        Offer memory invalidOffer = generateOffer(
            account1,
            senderTokenAddresses,
            senderTokenIds,
            block.chainid,
            account2,
            receiverTokenAddresses,
            receiverTokenIds,
            block.chainid,
            in6hours,
            OfferState.OPEN
        );
        bytes32 offerId = generateOfferId(invalidOffer);

        vm.prank(account1);
        vm.expectRevert(InvalidReceiver.selector);
        echo.cancelOffer(offerId);
    }

    function testCanCancelOfferSingleAsset() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        echo.cancelOffer(offerId);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is cancelled, it's also deleted
        assertEq(sender, address(0));

        // validate that the sender items are not in escrow
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);
        // validate that the receiver items are not in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }

    function testCanCancelOfferMultipleAssets() public {
        Offer memory offer = _createMultipleAssetsOffer();

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        echo.cancelOffer(offerId);

        (address sender,,,,,) = echo.offers(offerId);

        // @dev When the offer is cancelled, it's also deleted
        assertEq(sender, address(0));

        // validate that the sender items are not in escrow
        assertOfferItemsOwnership(offer.senderItems.items, offer.sender);
        // validate that the receiver items are not in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }
}
