// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract ExpirationTest is BaseTest {
    function testCannotCreateOfferIfAlreadyExpired() public {
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
            generateOffer(account1, senderItems, account2, receiverItems, block.timestamp, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(OfferHasExpired.selector);
        echo.createOffer(offer);
    }

    function testCannotCancelOfferIfAlreadyExpired() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.warp(in6hours);
        vm.prank(account1);
        vm.expectRevert(OfferHasExpired.selector);
        echo.cancelOffer(offerId);
    }

    function testCannotAcceptOfferIfAlreadyExpired() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.warp(in6hours);
        vm.prank(account2);
        vm.expectRevert(OfferHasExpired.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotExecuteOfferIfAlreadyExpired() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.warp(in6hours);
        vm.prank(account1);
        vm.expectRevert(OfferHasExpired.selector);
        echo.executeOffer(offerId);
    }

    function testSenderCannotRedeemOpenOfferIfNotExpired() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        vm.expectRevert(OfferHasNotExpired.selector);
        echo.redeemOffer(offerId);
    }

    function testReceiverCannotRedeemOpenOfferIfNotExpired() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(OfferHasNotExpired.selector);
        echo.redeemOffer(offerId);
    }

    function testSenderCannotRedeemAcceptedOfferIfNotExpired() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        vm.expectRevert(OfferHasNotExpired.selector);
        echo.redeemOffer(offerId);
    }

    function testReceiverCannotRedeemAcceptedOfferIfNotExpired() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(OfferHasNotExpired.selector);
        echo.redeemOffer(offerId);
    }
}
