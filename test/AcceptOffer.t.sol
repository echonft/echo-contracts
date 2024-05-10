// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./BaseTest.t.sol";
import "../src/types/OfferItems.sol";
import "../src/types/Offer.sol";

contract AcceptOfferTest is BaseTest {
    function testCannotAcceptOfferIfPaused() public {
        Offer memory offer = _createMockOffer();
        bytes32 offerId = generateOfferId(offer);
        _setPaused();

        vm.prank(account2);
        vm.expectRevert(Paused.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotAcceptOfferIfAlreadyExpired() public {
        Offer memory offer = _createMockOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.warp(in6hours);
        vm.prank(account2);
        vm.expectRevert(OfferHasExpired.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotAcceptNonExistentOffer() public {
        _createMockOffer();

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
        vm.expectRevert(OfferDoesNotExist.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotAcceptOfferIfNotEnoughFunds() public {
        _setFees();
        Offer memory offer = _createMockOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(InvalidPayment.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotAcceptOfferIfNotReceiver() public {
        Offer memory offer = _createMockOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account3);
        vm.expectRevert(InvalidReceiver.selector);
        echo.acceptOffer(offerId);
    }

    function testCanAcceptOfferSingleAsset() public {
        Offer memory offer = _createMockOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        echo.acceptOffer(offerId);

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
        address[] memory senderTokenAddresses = new address[](2);
        senderTokenAddresses[0] = apeAddress;
        senderTokenAddresses[1] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](2);
        senderTokenIds[0] = ape1Id;
        senderTokenIds[1] = ape2Id;

        address[] memory receiverTokenAddresses = new address[](2);
        receiverTokenAddresses[0] = birdAddress;
        receiverTokenAddresses[1] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](2);
        receiverTokenIds[0] = bird1Id;
        receiverTokenIds[1] = bird2Id;

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

        vm.prank(account1);
        echo.createOffer(offer);

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        echo.acceptOffer(offerId);

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
