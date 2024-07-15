// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract AcceptOfferTest is BaseTest {
    function testCannotAcceptNonExistentOffer() public {
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

        vm.prank(account2);
        vm.expectRevert(InvalidReceiver.selector);
        echo.acceptOffer(offerId);
    }

    function testCanAcceptOfferSingleAsset() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        Offer memory updatedOffer = Offer({
            sender: offer.sender,
            receiver: offer.receiver,
            senderItems: offer.senderItems,
            receiverItems: offer.receiverItems,
            expiration: offer.expiration,
            state: OfferState.ACCEPTED
        });

        (
            address sender,
            address receiver,
            OfferItems memory senderItems,
            OfferItems memory receiverItems,
            uint256 expiration,
            OfferState state
        ) = echo.offers(offerId);
        assertOfferEq(
            updatedOffer,
            Offer({
                sender: sender,
                receiver: receiver,
                senderItems: senderItems,
                receiverItems: receiverItems,
                expiration: expiration,
                state: state
            })
        );

        // validate that the sender items are in escrow
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));
        // validate that the receiver items are in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));
    }

    function testCanAcceptOfferMultipleAssets() public {
        Offer memory offer = _createAndAcceptMultipleAssetsOffer();
        bytes32 offerId = generateOfferId(offer);

        Offer memory updatedOffer = Offer({
            sender: offer.sender,
            receiver: offer.receiver,
            senderItems: offer.senderItems,
            receiverItems: offer.receiverItems,
            expiration: offer.expiration,
            state: OfferState.ACCEPTED
        });

        (
            address sender,
            address receiver,
            OfferItems memory senderItems,
            OfferItems memory receiverItems,
            uint256 expiration,
            OfferState state
        ) = echo.offers(offerId);
        assertOfferEq(
            updatedOffer,
            Offer({
                sender: sender,
                receiver: receiver,
                senderItems: senderItems,
                receiverItems: receiverItems,
                expiration: expiration,
                state: state
            })
        );

        // validate that the sender items are in escrow
        assertOfferItemsOwnership(offer.senderItems.items, address(echo));
        // validate that the receiver items are in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, address(echo));
    }
}
