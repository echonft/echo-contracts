// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.sol";
import "forge-std/Test.sol";

contract ApprovalTest is BaseTest {
    error InsufficientAllowance();

    function testCannotExecuteTradeIfSenderDidNotApprove() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape3Id;
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

        Offer memory offer = generateOffer(account3, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account3);
        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        echo.createOffer(offer);
    }

    function testCannotExecuteTradeIfSenderDidNotApproveERC20() public {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = wethAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = 0;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 10 ether;

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

        vm.startPrank(account1);
        weth.approve(address(echo), 9 ether);
        vm.expectRevert(InsufficientAllowance.selector);
        echo.createOffer(offer);
    }

    function testCannotExecuteTradeIfReceiverDidNotApprove() public {
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

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        echo.createOffer(offer);

        vm.startPrank(account2);
        birds.setApprovalForAll(address(echo), false);
        vm.stopPrank();

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectRevert(bytes("NOT_AUTHORIZED"));
        echo.acceptOffer(offerId);
    }

    function testCannotExecuteTradeIfReceiverDidNotApproveERC20() public {
        address[] memory senderTokenAddresses = new address[](3);
        senderTokenAddresses[0] = apeAddress;
        senderTokenAddresses[1] = apeAddress;
        senderTokenAddresses[2] = wethAddress;
        uint256[] memory senderTokenIds = new uint256[](3);
        senderTokenIds[0] = ape1Id;
        senderTokenIds[1] = ape2Id;
        senderTokenIds[2] = 0;
        uint256[] memory senderTokenAmounts = new uint256[](3);
        senderTokenAmounts[0] = 0;
        senderTokenAmounts[1] = 0;
        senderTokenAmounts[2] = 10 ether;

        address[] memory receiverTokenAddresses = new address[](3);
        receiverTokenAddresses[0] = birdAddress;
        receiverTokenAddresses[1] = birdAddress;
        receiverTokenAddresses[2] = usdtAddress;
        uint256[] memory receiverTokenIds = new uint256[](3);
        receiverTokenIds[0] = bird1Id;
        receiverTokenIds[1] = bird2Id;
        receiverTokenIds[2] = 0;
        uint256[] memory receiverTokenAmounts = new uint256[](3);
        receiverTokenAmounts[0] = 0;
        receiverTokenAmounts[1] = 0;
        receiverTokenAmounts[2] = 10000;

        OfferItems memory senderItems =
            generateOfferItems(senderTokenAddresses, senderTokenIds, senderTokenAmounts, block.chainid);
        OfferItems memory receiverItems =
            generateOfferItems(receiverTokenAddresses, receiverTokenIds, receiverTokenAmounts, block.chainid);

        Offer memory offer = generateOffer(account1, senderItems, account2, receiverItems, in6hours, OfferState.OPEN);

        vm.prank(account1);
        echo.createOffer(offer);
        vm.stopPrank();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        usdt.approve(address(echo), 0);
        vm.prank(account2);
        vm.expectRevert(InsufficientAllowance.selector);
        echo.acceptOffer(offerId);

        vm.prank(account2);
        usdt.approve(address(echo), 9000);
        vm.prank(account2);
        vm.expectRevert(InsufficientAllowance.selector);
        echo.acceptOffer(offerId);
    }
}
