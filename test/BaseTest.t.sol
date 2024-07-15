// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "./mock/Mocked721.sol";
import "./utils/OfferUtils.sol";
import "../src/Echo.sol";

abstract contract BaseTest is Test, OfferUtils {
    event OfferCreated(bytes32 indexed offerId);
    event OfferAccepted(bytes32 indexed offerId);
    event OfferCanceled(bytes32 indexed offerId);
    event OfferExecuted(bytes32 indexed offerId);

    // Exclude from coverage report
    function test() public override {}

    Echo public echo;

    Mocked721 public apes;
    Mocked721 public birds;

    address public constant owner = address(1313);
    address public constant account1 = address(1337);
    address public constant account3 = address(1339);
    address public constant account4 = address(1340);
    address public account2;
    uint256 public constant account2PrivateKey = 0xA11CE;
    address public signer;
    uint256 public constant signerPrivateKey = 0xB0B;

    address public apeAddress;
    uint256 public ape1Id;
    uint256 public ape2Id;
    uint256 public ape3Id;
    address public birdAddress;
    uint256 public bird1Id;
    uint256 public bird2Id;
    uint256 public bird3Id;

    function setUp() public {
        // Generate account2 and signer from private key.
        account2 = vm.addr(account2PrivateKey);
        signer = vm.addr(signerPrivateKey);

        // Fund accounts
        vm.deal(account1, 100 ether);
        vm.deal(account2, 100 ether);
        vm.deal(account3, 100 ether);
        vm.deal(account4, 100 ether);

        echo = new Echo(address(owner));

        apes = new Mocked721("Apes", "APE");
        birds = new Mocked721("Birds", "BIRD");

        apes.safeMint(account1, 1);
        apes.safeMint(account1, 2);
        apes.safeMint(account3, 3);

        birds.safeMint(account2, 1);
        birds.safeMint(account2, 2);
        birds.safeMint(account4, 3);

        apeAddress = address(apes);
        ape1Id = 1;
        ape2Id = 2;
        ape3Id = 3;
        birdAddress = address(birds);
        bird1Id = 1;
        bird2Id = 2;
        bird3Id = 3;

        vm.startPrank(account1);
        apes.setApprovalForAll(address(echo), true);
        vm.stopPrank();

        vm.startPrank(account2);
        birds.setApprovalForAll(address(echo), true);
        vm.stopPrank();

        in6hours = block.timestamp + (60 * 60 * 6);
    }

    function _createSingleAssetOffer() internal returns (Offer memory offer) {
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = apeAddress;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = ape1Id;

        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = birdAddress;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = bird1Id;

        offer = generateOffer(
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

        bytes32 offerId = generateOfferId(offer);
        vm.prank(account1);
        vm.expectEmit(true, true, true, true, address(echo));
        emit OfferCreated(offerId);
        echo.createOffer(offer);
        vm.stopPrank();
    }

    function _createMultipleAssetsOffer() internal returns (Offer memory offer) {
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

        offer = generateOffer(
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

        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        vm.expectEmit(true, true, true, true, address(echo));
        emit OfferCreated(offerId);
        echo.createOffer(offer);
        vm.stopPrank();
    }

    function _createAndAcceptSingleAssetOffer() internal returns (Offer memory offer) {
        uint256 tradingFee = echo.tradingFee();
        offer = _createSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectEmit(true, true, true, true, address(echo));
        emit OfferAccepted(offerId);
        echo.acceptOffer{value: tradingFee}(offerId);
        vm.stopPrank();
    }

    function _createAndAcceptMultipleAssetsOffer() internal returns (Offer memory offer) {
        uint256 tradingFee = echo.tradingFee();
        offer = _createMultipleAssetsOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account2);
        vm.expectEmit(true, true, true, true, address(echo));
        emit OfferAccepted(offerId);
        echo.acceptOffer{value: tradingFee}(offerId);
        vm.stopPrank();
    }

    function _executeSingleAssetOffer() internal returns (Offer memory offer) {
        uint256 tradingFee = echo.tradingFee();
        offer = _createAndAcceptSingleAssetOffer();
        bytes32 offerId = generateOfferId(offer);

        vm.prank(account1);
        vm.expectEmit(true, true, true, true, address(echo));
        emit OfferExecuted(offerId);
        echo.executeOffer{value: tradingFee}(offerId);
        vm.stopPrank();
    }

    function _setFees() internal {
        vm.prank(owner);
        echo.setFees(0.005 ether);
        vm.stopPrank();
    }

    function _setPaused() internal {
        vm.prank(owner);
        echo.setPaused(true);
        vm.stopPrank();
    }

    function _setCreationPaused() internal {
        vm.prank(owner);
        echo.setCreationPaused(true);
        vm.stopPrank();
    }
}
