// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract SignatureTest is BaseTest {
    /// Wrong signer
    function testInvalidSignature() public {
        creator721Assets.push(ape3);
        counterparty721Assets.push(bird3);
        Trade memory trade = Trade({
            id: "test",
            creator: account1,
            counterparty: account2,
            expiresAt: in6hours,
            creator721Assets: creator721Assets,
            counterparty721Assets: counterparty721Assets
        });
        uint256 wrongPrivateKey = _generatePrivateKey(testMnemonic, 1);
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, wrongPrivateKey);
        vm.prank(account1);
        vm.expectRevert(InvalidSignature.selector);
        echo.executeTrade(v, r, s, trade);
    }
}
