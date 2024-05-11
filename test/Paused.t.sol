// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
import "forge-std/Test.sol";

contract PausedTest is BaseTest {
    function testCannotCreateOfferIfPaused() public {
        _setPaused();

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

        vm.prank(account1);
        vm.expectRevert(Paused.selector);
        echo.createOffer(offer);
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
}
