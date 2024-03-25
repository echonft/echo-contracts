// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "src/Signer.sol";

// @dev Constants file for testing since we use private immutable on the main contract to save gas.
// Make sure this file is in sync with Signer.sol for the proper type hashes.

bytes32 constant TRADE_TYPEHASH = keccak256(
    "Trade(string id,address creator,address counterparty,uint256 expiresAt,address[] creatorCollections,uint256[] creatorIds,address[] counterpartyCollections,uint256[] counterpartyIds)"
);
bytes32 constant SIGNATURE_TYPEHASH = keccak256("Signature(uint8 v,bytes32 r,bytes32 s)");

abstract contract Constants {
    Signature public mockSignature = Signature({
        v: 28,
        r: 0x1ac3cd5c3835114c9bfb58984f010a0036d805934ec30918463de615cedffe7b,
        s: 0x02332013ae020ab4d85c6ae841a11ba4564cb9f3275afe8adde07c80ab14ae78
    });
}
