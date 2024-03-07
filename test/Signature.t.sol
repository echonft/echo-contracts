// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract SignatureTest is BaseTest {
    function testInvalidCounterpartySignature() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape3Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird3Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, signerPrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, signerPrivateKey);
        vm.prank(account1);
        vm.expectRevert(InvalidSignature.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testInvalidSignerSignature() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape3Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird3Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        (uint8 vSigner, bytes32 rSigner, bytes32 sSigner) = _signTrade(trade, account2PrivateKey);
        vm.prank(account1);
        vm.expectRevert(InvalidSigner.selector);
        echo.executeTrade(v, r, s, vSigner, rSigner, sSigner, trade);
    }

    function testHashTypedData() public {
        creator721Collections.push(apeAddress);
        creator721Ids.push(ape3Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird3Id);

        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creatorCollections: creator721Collections,
            creatorIds: creator721Ids,
            counterpartyCollections: counterparty721Collections,
            counterpartyIds: counterparty721Ids
        });

        bytes32 structHash = keccak256(
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
        bytes32 expectedDigest = keccak256(abi.encodePacked("\x19\x01", echo.domainSeparator(), structHash));
        // Check hash struct
        assertEq(echo.hashTypedData(structHash), expectedDigest);

        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, account2PrivateKey);
        address recoveredAddress = ecrecover(expectedDigest, v, r, s);
        assertEq(recoveredAddress, trade.counterparty);
    }

    function testDomainSeparator() public {
        bytes32 expectedDomainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("Echo"),
                keccak256("1"),
                block.chainid,
                address(echo)
            )
        );

        assertEq(echo.domainSeparator(), expectedDomainSeparator);
    }

    struct _testEIP5267Variables {
        bytes1 fields;
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
        bytes32 salt;
        uint256[] extensions;
    }

    function testEIP5267() public {
        _testEIP5267Variables memory t;
        (t.fields, t.name, t.version, t.chainId, t.verifyingContract, t.salt, t.extensions) = echo.eip712Domain();

        assertEq(t.fields, hex"0f");
        assertEq(t.name, "Echo");
        assertEq(t.version, "1");
        assertEq(t.chainId, block.chainid);
        assertEq(t.verifyingContract, address(echo));
        assertEq(t.salt, bytes32(0));
        assertEq(t.extensions, new uint256[](0));
    }
}
