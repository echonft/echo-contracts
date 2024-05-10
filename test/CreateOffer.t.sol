// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract CreateOfferTest is BaseTest {
    function testCannotCreateOfferIfReceiverItemsIsEmpty() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;

        address[] memory receiverTokenAddresses = new address[](0);
        uint256[] memory receiverTokenIds = new uint256[](0);

        Offer memory offer = generateOffer(
            account1,
            senderTokenAddresses,
            senderTokenIds,
            block.chainid,
            account2,
            receiverTokenAddresses,
            receiverTokenIds,
            block.chainid,
            in6hours,
            OfferState.ACCEPTED
        );

        vm.prank(account1);
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfSenderItemsIsEmpty() public {
        address[] memory senderTokenAddresses = new address[](0);
        uint256[] memory senderTokenIds = new uint256[](0);

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;

        Offer memory offer = generateOffer(
            account1,
            senderTokenAddresses,
            senderTokenIds,
            block.chainid,
            account2,
            receiverTokenAddresses,
            receiverTokenIds,
            block.chainid,
            in6hours,
            OfferState.ACCEPTED
        );

        vm.prank(account1);
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfStateNotOpen() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;

        Offer memory offer = generateOffer(
            account1,
            senderTokenAddresses,
            senderTokenIds,
            block.chainid,
            account2,
            receiverTokenAddresses,
            receiverTokenIds,
            block.chainid,
            in6hours,
            OfferState.ACCEPTED
        );

        vm.prank(account1);
        vm.expectRevert(InvalidOfferState.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfNotSender() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;

        Offer memory offer = generateOffer(
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

        vm.prank(account2);
        vm.expectRevert(InvalidSender.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateDuplicateOffer() public {
        Offer memory firstOffer = _createMockOffer();

        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;

        Offer memory secondOffer = generateOffer(
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

        vm.prank(account1);
        vm.expectRevert(OfferAlreadyExist.selector);
        echo.createOffer(secondOffer);
    }
    // Creating a same chain offer

    function testCanCreateOfferSingleAsset() public {
        Offer memory offer = _createMockOffer();

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
