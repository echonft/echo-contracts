// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.t.sol";
import "./mock/MockHandler.t.sol";
import "./utils/Constants.sol";
import "forge-std/Test.sol";
import "src/Echo.sol";

abstract contract BaseTest is Test, Constants {
    // Exclude from coverage report
    function test() public {}

    event TradeExecuted(string id);

    Echo public echo;
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

        echo = new Echo({owner: owner, signer: signer});
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

    // @dev Sign the trade with private key
    function _signTrade(Trade memory trade, uint256 privateKey) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 hashStruct = keccak256(
            abi.encode(
                TRADE_TYPEHASH,
                keccak256(bytes(trade.id)),
                trade.creator,
                trade.counterparty,
                trade.expiresAt,
                keccak256(abi.encodePacked(trade.creatorCollections)), // address[]
                keccak256(abi.encodePacked(trade.creatorIds)), // uint256[]
                keccak256(abi.encodePacked(trade.counterpartyCollections)), // address[]
                keccak256(abi.encodePacked(trade.counterpartyIds)) // uint256[]
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", echo.domainSeparator(), hashStruct));
        (v, r, s) = vm.sign(privateKey, digest);
    }

    // @dev Sign the signature with the private key. This is simulating the backend signing
    function _signSignature(Signature memory signature, uint256 privateKey)
        internal
        view
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        bytes32 hashStruct = keccak256(abi.encode(SIGNATURE_TYPEHASH, signature.v, signature.r, signature.s));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", echo.domainSeparator(), hashStruct));
        (v, r, s) = vm.sign(privateKey, digest);
    }

    // @dev Util function to generate the backend signature of the trade, returns all the data to execute the trade
    function _prepareSignature(Trade memory trade, uint256 counterpartyPrivateKey, uint256 _signerPrivateKey)
        internal
        view
        returns (uint8 vSigner, bytes32 rSigner, bytes32 sSigner, Signature memory signature)
    {
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, counterpartyPrivateKey);
        signature = Signature({v: v, r: r, s: s});
        (vSigner, rSigner, sSigner) = _signSignature(signature, _signerPrivateKey);
    }

    // @dev Method to execute a mock trade with predefined values
    // @dev Do not use this method if you expect a revert as the way Foundry is built, it won't catch the revert
    function _executeMockTrade(string memory id, address creator, address counter, uint256 fees) internal {
        Trade memory trade = Trade({
            id: id,
            creator: creator,
            counterparty: counter,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        Signature memory signature = Signature({v: v, r: r, s: s});
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signSignature(signature, signerPrivateKey);
        vm.prank(creator);
        echo.executeTrade{value: fees}(vSigner, rSigner, sSigner, signature, trade);
    }
}
