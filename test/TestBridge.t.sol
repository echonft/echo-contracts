// SPDX-License-Identifier: Apache 2
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "./mock/Mocked721.t.sol";
import "./utils/WormholeSimulator.sol";
import "contracts/EchoCrossChain.sol";
import "contracts/escrow/EscrowData.sol";
import "contracts/wormhole/WormholeData.sol";

/**
 * @title A Test Suite for the EVM EchoCrossChain Contracts
 */
contract TestBridge is Test {
    // guardian private key for simulated signing of Wormhole messages
    uint256 guardianSigner;

    // contract instances
    IWormhole wormhole;
    WormholeSimulator wormholeSimulator;
    EchoCrossChain echoSource;
    EchoCrossChain echoTarget;

    address public constant owner = address(1313);
    address public constant sender = address(1337);
    address public constant receiver = address(1339);

    Mocked721 public apes;
    Mocked721 public birds;

    address public apeAddress;
    uint256 public ape1Id;
    address public birdAddress;
    uint256 public bird1Id;

    /**
     * @notice Sets up the wormholeSimulator contracts and deploys HelloWorld
     * contracts before each test is executed.
     */
    function setUp() public {
        // Fund accounts
        vm.deal(sender, 100 ether);
        vm.deal(receiver, 100 ether);

        apes = new Mocked721("Apes", "APE");
        birds = new Mocked721("Birds", "BIRD");

        apes.safeMint(sender, 1);

        birds.safeMint(receiver, 1);

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

        echoSource = new EchoCrossChain(address(owner), address(wormhole), wormhole.chainId(), uint8(1));
        echoTarget = new EchoCrossChain(address(owner), address(wormhole), uint8(2), uint8(1));

        // confirm that the source and target contract addresses are different
        assertTrue(address(echoSource) != address(echoTarget));
    }

    function testAcceptTrade() public {
        // start listening to events
        vm.recordLogs();

        bytes32 evmSender = bytes32(uint256(uint160(sender)) << 96);
        bytes32 evmReceiver = bytes32(uint256(uint160(receiver)) << 96);
        bytes32 evmTokenAddress = bytes32(uint256(uint160(address(birds))) << 96);
        uint64 evmTokenId = uint64(1);
        bytes32 solSender = bytes32(0);
        bytes32 solReceiver = bytes32(0);
        bytes32 solSenderTokenMint = bytes32(0);

        EchoMessageWithoutPayload memory message = EchoMessageWithoutPayload({
            id: "test",
            evmSender: evmSender,
            evmReceiver: evmReceiver,
            evmTokenAddress: evmTokenAddress,
            evmTokenId: evmTokenId,
            solSender: solSender,
            solReceiver: solReceiver,
            solSenderTokenMint: solSenderTokenMint
        });
        echoTarget._sendMessage(message);

        // record the emitted wormhole message
        Vm.Log[] memory entries = vm.getRecordedLogs();

        // simulate signing the Wormhole message
        // NOTE: in the wormhole-sdk, signed Wormhole messages are referred to as signed VAAs
        bytes memory encodedMessage =
            wormholeSimulator.fetchSignedMessageFromLogs(entries[0], echoTarget.chainId(), address(echoTarget));

        vm.startPrank(owner);
        // register the emitter on the source contract
        echoSource.registerEmitter(echoTarget.chainId(), bytes32(uint256(uint160(address(echoTarget)))));
        vm.stopPrank();

        vm.startPrank(receiver);
        echoSource.acceptOffer(
            "test",
            Offer({
                sender: sender,
                receiver: receiver,
                expiresAt: block.timestamp + (60 * 60 * 6),
                status: OfferStatus.Created,
                receiver721Asset: ERC721Asset({collection: address(birds), id: evmTokenId})
            }),
            encodedMessage
        );

        // Parse the encodedMessage to retrieve the hash. This is a safe operation
        // since the source HelloWorld contract already verfied the message in the
        // previous call.
        IWormhole.VM memory parsedMessage = wormhole.parseVM(encodedMessage);

        // Verify that the message was consumed and the payload was saved
        // in the contract state.
        bool messageWasConsumed = echoSource.isMessageConsumed(parsedMessage.hash);

        assertTrue(messageWasConsumed);

        // Confirm that message replay protection works by trying to call receiveMessage
        // with the same Wormhole message again.
        vm.expectRevert("message already consumed");
        echoSource._receiveMessage(encodedMessage);
    }
}
