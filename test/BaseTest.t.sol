// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";
import "src/Echo.sol";

abstract contract BaseTest is Test {
    event TradeExecuted(string indexed id, address user);

    Echo echo;

    Mocked721 apes;
    Mocked721 birds;

    address constant owner = address(1313);
    address constant account1 = address(1337);
    address constant account3 = address(1339);
    address constant account4 = address(1340);
    address constant refer = address(1341);

    // For signing
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant TRADE_TYPEHASH = keccak256(
        "Trade(string id,address creator,address counterparty,uint256 expiresAt,ERC721Asset[] creator721Assets,ERC721Asset[] counterparty721Assets)ERC721Asset(address collection,uint64 id)"
    );

    ERC721Asset ape1;
    ERC721Asset ape2;
    ERC721Asset ape3;
    ERC721Asset bird1;
    ERC721Asset bird2;
    ERC721Asset bird3;

    ERC721Asset[] creator721Assets;
    ERC721Asset[] counterparty721Assets;

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

        apes = new Mocked721("Apes", "APE");
        birds = new Mocked721("Birds", "BIRD");

        apes.safeMint(account1, 1);
        apes.safeMint(account1, 2);
        apes.safeMint(account3, 3);

        birds.safeMint(account2, 1);
        birds.safeMint(account2, 2);
        birds.safeMint(account4, 3);

        ape1 = ERC721Asset(address(apes), 1);
        ape2 = ERC721Asset(address(apes), 2);
        ape3 = ERC721Asset(address(apes), 3);
        bird1 = ERC721Asset(address(birds), 1);
        bird2 = ERC721Asset(address(birds), 2);
        bird3 = ERC721Asset(address(birds), 3);

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
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH, keccak256(bytes("ExecuteTrade")), keccak256(bytes("1")), chainId, address(echo)
            )
        );

        bytes32 hashStruct = keccak256(
            abi.encode(
                TRADE_TYPEHASH,
                trade.id,
                trade.creator,
                trade.counterparty,
                trade.expiresAt,
                trade.creator721Assets,
                trade.counterparty721Assets
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
        (v, r, s) = vm.sign(privateKey, digest);
    }

    function _executeTrade(string memory id, address creator, address counter, uint256 fees) internal {
        Trade memory trade = Trade({
            id: id,
            creator: creator,
            counterparty: counter,
            expiresAt: in6hours,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);

        vm.prank(creator);
        echo.executeTrade{value: fees}(v, r, s, trade);
    }
}
