// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.sol";
import "./mock/MockHandler.sol";
import "./mock/WormholeSimulator.sol";
import "contracts/EchoCrossChain.sol";
import "contracts/wormhole/IWormhole.sol";
import "forge-std/Test.sol";

abstract contract BaseTest is Test {
    // Exclude from coverage report
    function test() public {}

    // guardian private key for simulated signing of Wormhole messages
    uint256 guardianSigner;

    // contract instances
    IWormhole wormhole;
    WormholeSimulator wormholeSimulator;

    EchoCrossChain public echo;
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

    uint256 public in6hours;

    function setUp() public {
        // Generate account2 and signer from private key.
        account2 = vm.addr(account2PrivateKey);
        signer = vm.addr(signerPrivateKey);

        // Fund accounts
        vm.deal(account1, 100 ether);
        vm.deal(account2, 100 ether);
        vm.deal(account3, 100 ether);
        vm.deal(account4, 100 ether);

        /* Initialize wormhole */
        // verify that we're using the correct fork (AVAX mainnet in this case)
        require(block.chainid == vm.envUint("TESTING_AVAX_FORK_CHAINID"), "wrong evm");

        // this will be used to sign Wormhole messages
        guardianSigner = uint256(vm.envBytes32("TESTING_DEVNET_GUARDIAN"));

        // we may need to interact with Wormhole throughout the test
        wormhole = IWormhole(vm.envAddress("TESTING_AVAX_WORMHOLE_ADDRESS"));

        // set up Wormhole using Wormhole existing on AVAX mainnet
        wormholeSimulator = new SigningWormholeSimulator(wormhole, guardianSigner);

        // verify Wormhole state from fork
        require(wormhole.chainId() == uint16(vm.envUint("TESTING_AVAX_WORMHOLE_CHAINID")), "wrong chainId");
        require(wormhole.messageFee() == vm.envUint("TESTING_AVAX_WORMHOLE_MESSAGE_FEE"), "wrong messageFee");
        require(
            wormhole.getCurrentGuardianSetIndex() == uint32(vm.envUint("TESTING_AVAX_WORMHOLE_GUARDIAN_SET_INDEX")),
            "wrong guardian set index"
        );

        echo = new EchoCrossChain(address(owner), address(wormhole), wormhole.chainId(), uint8(1));
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
