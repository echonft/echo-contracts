// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
import "forge-std/Test.sol";

contract OwnershipTest is BaseTest {
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

    function testCannotCancelOfferIfNotSender() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account3);
        vm.expectRevert(InvalidReceiver.selector);
        echo.cancelOffer(offerId);
    }

    function testCannotAcceptOfferIfNotReceiver() public {
        Offer memory offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account3);
        vm.expectRevert(InvalidReceiver.selector);
        echo.acceptOffer(offerId);
    }

    function testCannotExecuteOfferIfNotSender() public {
        Offer memory offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(InvalidSender.selector);
        echo.executeOffer(offerId);
    }
}
