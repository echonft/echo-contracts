// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "solmate/utils/ReentrancyGuard.sol";
import "./Handler.sol";
import "forge-std/console.sol";
import "solady/src/utils/ECDSA.sol";
import "solady/src/utils/EIP712.sol";

error InvalidSignature();

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

abstract contract Signer is EIP712 {
    using ECDSA for bytes32;

    bytes32 private constant TRADE_TYPEHASH = keccak256(
        "Trade(string id,address creator,address counterparty,uint256 expiresAt,address[] creatorCollections,uint256[] creatorIds,address[] counterpartyCollections,uint256[] counterpartyIds)"
    );

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

    function _validateSignature(uint8 v, bytes32 r, bytes32 s, Trade memory trade) internal view {
        bytes32 structHash = keccak256(
            abi.encode(
                TRADE_TYPEHASH,
                trade.id,
                trade.creator,
                trade.counterparty,
                trade.expiresAt,
                trade.creatorCollections,
                trade.creatorIds,
                trade.counterpartyCollections,
                trade.counterpartyIds
            )
        );
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", this.domainSeparator(), structHash));
        address signer = ECDSA.recover(hash, v, r, s);

        console.logAddress(signer);
        console.logAddress(trade.counterparty);
        console.logAddress(trade.creator);

        if (signer != trade.counterparty) revert InvalidSignature();
    }
}
