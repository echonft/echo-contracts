// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../BaseTest.t.sol";
import "../mock/Mocked721.t.sol";
import "forge-std/Test.sol";

// @dev Only used to test live signature, the function contains all the data prefilled.
//      Simply edit the trade and the signature to see if it will work.
contract SignatureTesterTest is BaseTest {
    function testSignature() public {
        // @dev Might need to modify chain Id and contract address to test here
        bytes32 expectedDomainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("Echo"),
                keccak256("1"),
                11155111, // chain Id
                0x07d31999C2BAe29086133A5C93b07a481c5dDaea // echo live address
            )
        );

        // @dev Creator and Counterparty offer items
        creator721Collections.push(0x65426F3C04e85936b0F875510d045b413134186A);
        creator721Ids.push(0);
        counterparty721Collections.push(0x65426F3C04e85936b0F875510d045b413134186A);
        counterparty721Collections.push(0x65426F3C04e85936b0F875510d045b413134186A);
        counterparty721Ids.push(5);
        counterparty721Ids.push(6);

        // @dev Rest of the data for the offer
        Trade memory trade = Trade({
            id: "mrAEqcvejrukUv9uH2aj",
            creator: 0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09,
            counterparty: 0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af,
            expiresAt: 1698165207,
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

        bytes32 expectedDigest = keccak256(abi.encodePacked("\x19\x01", expectedDomainSeparator, structHash));
        bytes memory signature =
            hex"0c972a2bd54f7cdc8ed7d7a3f184b9a46555678be59ba7073ed2c4ecdab74e457b2bd46c713bc06646ab8550ba7f0e08d30241df55c24ebf614c63d22e580ef71c";
        (bytes32 r, bytes32 s, uint8 v) = _splitSignature(signature);
        address recoveredAddress = ecrecover(expectedDigest, v, r, s);
        console.log(recoveredAddress);
        assertEq(recoveredAddress, trade.counterparty);
    }

    function _splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
