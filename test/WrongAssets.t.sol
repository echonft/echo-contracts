// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "forge-std/Test.sol";

contract WrongAssetsTest is BaseTest {
    function testCannotCreateOfferIfReceiverItemsIsEmpty() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;

        address[] memory receiverTokenAddresses = new address[](0);
        uint256[] memory receiverTokenIds = new uint256[](0);
        uint256[] memory receiverTokenAmounts = new uint256[](0);

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateOfferIfSenderItemsIsEmpty() public {
        address[] memory senderTokenAddresses = new address[](0);
        uint256[] memory senderTokenIds = new uint256[](0);
        uint256[] memory senderTokenAmounts = new uint256[](0);

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
        vm.expectRevert(InvalidAssets.selector);
        echo.createOffer(offer);
    }

    function testCannotCreateSameCreatorAssets() public {
        address[] memory senderTokenAddresses = new address[](2);
        senderTokenAddresses[0] = apeAddress;
        senderTokenAddresses[1] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](2);
        senderTokenIds[0] = ape1Id;
        senderTokenIds[1] = ape1Id;
        uint256[] memory senderTokenAmounts = new uint256[](2);
        senderTokenAmounts[0] = 0;
        senderTokenAmounts[1] = 0;

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
        vm.expectRevert("WRONG_FROM");
        echo.createOffer(offer);
    }

    function testCannotAcceptSameCounterpartyAssets() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;

        address[] memory receiverTokenAddresses = new address[](2);
        receiverTokenAddresses[0] = birdAddress;
        receiverTokenAddresses[1] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](2);
        receiverTokenIds[0] = bird1Id;
        receiverTokenIds[1] = bird1Id;
        uint256[] memory receiverTokenAmounts = new uint256[](2);
        receiverTokenAmounts[0] = 0;
        receiverTokenAmounts[1] = 0;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        echo.createOffer(offer);

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert("WRONG_FROM");
        echo.acceptOffer(offerId);
    }
}
