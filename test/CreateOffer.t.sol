// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract CreateOfferTest is BaseTest {
    function testCannotCreateOfferIfStateNotOpen() public {
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

        Offer memory offer =
            generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.ACCEPTED);

        vm.prank(account1);
        vm.expectRevert(InvalidOfferState.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfSenderItemsNotOnProperChain() public {
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

        OfferItems memory senderItems = generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, 10);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfReceiverItemsNotOnProperChain() public {
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
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, 10);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCanCreateOfferSingleAsset() public {
        Offer memory offer = _createSingleAssetOffer();

        // validate the offer id
        bytes32 offerId = generateOfferId(offer);
        (
            address sender,
            address receiver,
            OfferItems memory senderItems,
            OfferItems memory receiverItems,
            uint256 expiration,
            OfferState state
        ) = echo.offers(offerId);
        assertOfferEq(
            offer,
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
        // validate that the receiver items are not in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }

    function testCanCreateOfferMultipleAssets() public {
        Offer memory offer = _createMultipleAssetsOffer();

        // validate the offer id
        bytes32 offerId = generateOfferId(offer);
        (
            address sender,
            address receiver,
            OfferItems memory senderItems,
            OfferItems memory receiverItems,
            uint256 expiration,
            OfferState state
        ) = echo.offers(offerId);
        assertOfferEq(
            offer,
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
        // validate that the receiver items are not in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }

    function testCanCreateOfferMultipleTokens() public {
        Offer memory offer = _createMultiTokensOffer();

        // validate the offer id
        bytes32 offerId = generateOfferId(offer);
        (
            address sender,
            address receiver,
            OfferItems memory senderItems,
            OfferItems memory receiverItems,
            uint256 expiration,
            OfferState state
        ) = echo.offers(offerId);
        assertOfferEq(
            offer,
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
        // validate that the receiver items are not in escrow
        assertOfferItemsOwnership(offer.receiverItems.items, offer.receiver);
    }
}
