// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "contracts/AdminSigner.sol";
import "contracts/Banker.sol";
import "contracts/Handler.sol";
import "contracts/Signer.sol";
import "solmate/utils/ReentrancyGuard.sol";

error TradeAlreadyExist();
error TradeHasExpired();
error InvalidCreator();
error InvalidAssets();
error InvalidPayment();

contract Echo is ReentrancyGuard, AdminSigner, Handler, Banker, Signer {
    event TradeExecuted(string id);

    constructor(address owner, address signer) AdminSigner(owner, signer) {}

    /// @dev Only executed trades are on chain to avoid replay attacks
    /// Trades are mapped by id
    mapping(string => bool) internal trades;

    function executeTrade(uint8 v, bytes32 r, bytes32 s, Signature calldata signatureData, Trade calldata trade)
        external
        payable
        nonReentrant
        notPaused
    {
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

        _validateSignature(v, r, s, signatureData, signer);
        _validateTrade(signatureData, trade);

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
