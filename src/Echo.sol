// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./Admin.sol";
import "./Banker.sol";
import "./Handler.sol";
import "./Signer.sol";
import "solmate/utils/ReentrancyGuard.sol";

error TradeAlreadyExist();
error TradeHasExpired();
error InvalidCreator();
error InvalidAssets();
error InvalidPayment();

contract Echo is ReentrancyGuard, Admin, Handler, Banker, Signer {
    event TradeExecuted(string id);

    constructor(address owner, address signer) Admin(owner, signer) {}

    /// @dev Only executed trades are on chain to avoid replay attacks
    /// Trades are mapped by id
    mapping(string => bool) trades;

    function executeTrade(
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint8 vSigner,
        bytes32 rSigner,
        bytes32 sSigner,
        Trade calldata trade
    ) external payable nonReentrant notPaused {
        if (trades[trade.id]) {
            revert TradeAlreadyExist();
        }

        if (trade.creator != msg.sender) {
            revert InvalidCreator();
        }

        // We only check that length is not 0 here because we check the length in the transfer method
        if (trade.creatorCollections.length == 0 || trade.counterpartyCollections.length == 0) {
            revert InvalidAssets();
        }

        if (trade.expiresAt <= block.timestamp) {
            revert TradeHasExpired();
        }

        if (msg.value != tradingFee) {
            revert InvalidPayment();
        }

        _validateSigner(vSigner, rSigner, sSigner, signer, trade);
        _validateSignature(v, r, s, trade);

        // Transfer creator's assets
        _transferTokens({
            collections: trade.creatorCollections,
            ids: trade.creatorIds,
            from: trade.creator,
            to: trade.counterparty
        });

        // Transfer counterparty's assets
        _transferTokens({
            collections: trade.counterpartyCollections,
            ids: trade.counterpartyIds,
            from: trade.counterparty,
            to: trade.creator
        });

        // Add trade to list to avoid replay and duplicates
        trades[trade.id] = true;

        emit TradeExecuted(trade.id);
    }
}
