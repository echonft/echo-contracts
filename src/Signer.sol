// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "solmate/utils/ReentrancyGuard.sol";
import "./Handler.sol";

error InvalidSignature();
error ECDSAInvalidSignature();

struct Trade {
    string id;
    address creator;
    address counterparty;
    uint256 expiresAt;
    ERC721Asset[] creator721Assets;
    ERC721Asset[] counterparty721Assets;
}

abstract contract Signer {
    bytes32 private constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private constant TRADE_TYPEHASH = keccak256(
        "Trade(string id,address creator,address counterparty,uint256 expiresAt,ERC721Asset[] creator721Assets,ERC721Asset[] counterparty721Assets)ERC721Asset(address collection,uint64 id)"
    );

    function _validateSignature(uint8 v, bytes32 r, bytes32 s, Trade memory trade) internal view {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        bytes32 eip712DomainHash = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH, keccak256(bytes("ExecuteTrade")), keccak256(bytes("1")), chainId, address(this)
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

        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", eip712DomainHash, hashStruct));
        address signer = ecrecover(hash, v, r, s);

        if (signer != trade.counterparty) revert InvalidSignature();
        if (signer == address(0)) revert ECDSAInvalidSignature();
    }
}
