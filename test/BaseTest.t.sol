// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.t.sol";
import "./mock/MockHandler.t.sol";
import "forge-std/Test.sol";
import "src/Echo.sol";

abstract contract BaseTest is Test {
    // Exclude from coverage report
    function test() public {}

    event TradeExecuted(address indexed owner, address indexed counterparty, string id);

    Echo echo;
    // To test internal function as it's impossible to reach the code
    // from echo (echo also checks for length)
    MockedHandler handler;

    Mocked721 apes;
    Mocked721 birds;

    address constant owner = address(1313);
    address constant account1 = address(1337);
    address constant account3 = address(1339);
    address constant account4 = address(1340);
    address constant refer = address(1341);

    // For signing
    bytes32 internal constant TRADE_TYPEHASH = keccak256(
        "Trade(string id,address creator,address counterparty,uint256 expiresAt,address[] creatorCollections,uint256[] creatorIds,address[] counterpartyCollections,uint256[] counterpartyIds)"
    );

    address apeAddress;
    uint256 ape1Id;
    uint256 ape2Id;
    uint256 ape3Id;
    address birdAddress;
    uint256 bird1Id;
    uint256 bird2Id;
    uint256 bird3Id;

    address[] creator721Collections;
    uint256[] creator721Ids;
    address[] counterparty721Collections;
    uint256[] counterparty721Ids;

    uint256 in6hours;

    string constant testMnemonic = "test test test test test test test test test test test junk";
    address account2;
    uint256 account2PrivateKey;

    function setUp() public {
        // Generate account2 from mnemonic to get private key.
        account2PrivateKey = _generatePrivateKey(testMnemonic, 0);
        account2 = vm.addr(account2PrivateKey);

        // Fund accounts
        vm.deal(account1, 100 ether);
        vm.deal(account2, 100 ether);
        vm.deal(account3, 100 ether);
        vm.deal(account4, 100 ether);

        echo = new Echo({owner: owner});
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

    function _generatePrivateKey(string memory mnemonic, uint32 index) internal pure returns (uint256 privateKey) {
        privateKey = vm.deriveKey(mnemonic, index);
    }

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

    function _executeTrade(string memory id, address creator, address counter, uint256 fees) internal {
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

        vm.prank(creator);
        echo.executeTrade{value: fees}(v, r, s, trade);
    }
}
