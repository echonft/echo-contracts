// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Admin.sol";
import "./Banker.sol";
import "./Handler.sol";
import "./Signer.sol";
import "solmate/utils/ReentrancyGuard.sol";

error TradeAlreadyExist();
error TradeIsNotExpired();
error TradeHasExpired();
error InvalidExpiration();
error InvalidCreator();
error InvalidCounterparty();
error InvalidAssets();
error UserNotInTrade();
error UserDontHaveEscrow();
error InvalidPayment();

contract Echo is ReentrancyGuard, Admin, Handler, Banker, Signer {
    event TradeExecuted(string indexed id, address user);

    constructor(address owner) Admin(owner) {}

    /// @dev Only executed trades are on chain to avoid replay attacks
    /// Trades are mapped by id
    mapping(string => bool) trades;


    function executeTrade(
        uint8 v,
        bytes32 r,
        bytes32 s,
        Trade memory trade
    )
        external
        payable
        nonReentrant
        notPaused
        tradeExists(trade.id)
    {
        if (trade.creator != msg.sender) {
            revert InvalidCreator();
        }

        if (trade.creator721Assets.length == 0 || trade.counterparty721Assets.length == 0) {
            revert InvalidAssets();
        }

        if (trade.expiresAt <= block.timestamp) {
            revert InvalidExpiration();
        }

        _validateSignature(v, r, s, trade);

        // Transfer creator's assets
        _transferTokens({
            tokens: trade.creator721Assets,
            from: trade.creator,
            to: trade.counterparty
        });

        // Transfer counterparty's assets
        _transferTokens({
            tokens: trade.counterparty721Assets,
            from: trade.counterparty,
            to: trade.creator
        });

        // Add trade to list to avoid replay and duplicates
        trades[trade.id] = true;

        emit TradeExecuted(trade.id, msg.sender);
    }


    modifier tradeExists(string memory id) {
        if (trades[id]) {
            revert TradeAlreadyExist();
        }

        _;
    }
    
}
