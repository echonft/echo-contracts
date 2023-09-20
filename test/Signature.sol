// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract SignatureTest is BaseTest {
    /// Wrong signer
    function testInvalidSignature() public {
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
        uint256 wrongPrivateKey = _generatePrivateKey(testMnemonic, 1);
        (uint8 v, bytes32 r, bytes32 s) = _signTrade(trade, wrongPrivateKey);
        vm.prank(account1);
        vm.expectRevert(InvalidSignature.selector);
        echo.executeTrade(v, r, s, trade);
    }
}
