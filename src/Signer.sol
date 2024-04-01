// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/utils/ReentrancyGuard.sol";
import "./Handler.sol";
import "solady/src/utils/ECDSA.sol";
import "solady/src/utils/EIP712.sol";

error InvalidSignature();
error InvalidSigner();

struct Trade {
    string id;
    address creator;
    address counterparty;
    uint256 expiresAt;
    address[] creatorCollections;
    uint256[] creatorIds;
    address[] counterpartyCollections;
    uint256[] counterpartyIds;
}

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

abstract contract Signer is EIP712 {
    using ECDSA for bytes32;
    using ECDSA for bytes;

    bytes32 private immutable TRADE_TYPEHASH = keccak256(
        "Trade(string id,address creator,address counterparty,uint256 expiresAt,address[] creatorCollections,uint256[] creatorIds,address[] counterpartyCollections,uint256[] counterpartyIds)"
    );

    bytes32 private immutable SIGNATURE_TYPEHASH = keccak256("Signature(uint8 v,bytes32 r,bytes32 s)");

    function _domainNameAndVersion() internal pure override returns (string memory name, string memory version) {
        name = "Echo";
        version = "1";
    }

    function hashTypedData(bytes32 structHash) external view returns (bytes32) {
        return _hashTypedData(structHash);
    }

    function domainSeparator() external view returns (bytes32) {
        return _domainSeparator();
    }

    function _validateTrade(Signature calldata signatureData, Trade calldata trade) internal view {
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
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", this.domainSeparator(), structHash));
        if (ECDSA.recover(hash, signatureData.v, signatureData.r, signatureData.s) != trade.counterparty) {
            revert InvalidSignature();
        }
    }

    function _validateSignature(uint8 v, bytes32 r, bytes32 s, Signature calldata signatureData, address signer)
        internal
        view
    {
        bytes32 structHash =
            keccak256(abi.encode(SIGNATURE_TYPEHASH, signatureData.v, signatureData.r, signatureData.s));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", this.domainSeparator(), structHash));
        if (ECDSA.recover(hash, v, r, s) != signer) revert InvalidSigner();
    }
}
