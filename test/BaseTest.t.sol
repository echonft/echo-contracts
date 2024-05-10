// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.sol";
import "./mock/MockHandler.sol";
import "./mock/WormholeSimulator.sol";
import "forge-std/Test.sol";
import "./utils/OfferUtils.sol";
import "../src/EchoCrossChain.sol";

abstract contract BaseTest is Test, OfferUtils {
    // Exclude from coverage report
    function test() public {}

    EchoCrossChain public echo;

    // TODO Remove?
    // To test internal function as it's impossible to reach the code
    // from echo (echo also checks for length)
    MockedHandler public handler;

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

    address[] public creator721Collections;
    uint256[] public creator721Ids;
    address[] public counterparty721Collections;
    uint256[] public counterparty721Ids;

    function setUp() public {
        // Generate account2 and signer from private key.
        account2 = vm.addr(account2PrivateKey);
        signer = vm.addr(signerPrivateKey);

        // Fund accounts
        vm.deal(account1, 100 ether);
        vm.deal(account2, 100 ether);
        vm.deal(account3, 100 ether);
        vm.deal(account4, 100 ether);

        echo = new EchoCrossChain(address(owner));
        handler = new MockedHandler();

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

    function _createMockOffer() internal returns (Offer memory offer) {
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

        vm.prank(account1);
        echo.createOffer(offer);
    }

    // @dev Method to execute a mock trade with predefined values
    // @dev Do not use this method if you expect a revert as the way Foundry is built, it won't catch the revert
    function _executeMockTrade(string memory id, address creator, address counter, uint256 fees) internal {
        //        Trade memory trade = Trade({
        //            id: id,
        //            creator: creator,
        //            counterparty: counter,
        //            expiresAt: in6hours,
        //            creatorCollections: creator721Collections,
        //            creatorIds: creator721Ids,
        //            counterpartyCollections: counterparty721Collections,
        //            counterpartyIds: counterparty721Ids
        //        });
        //        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        //        Signature memory signature = Signature({v: v, r: r, s: s});
        //        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signSignature(
        //            signature,
        //            signerPrivateKey
        //        );
        //        vm.prank(creator);
        //        echo.executeTrade{value: fees}(vSigner, rSigner, sSigner, signature, trade);
    }
}
