// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./BaseTest.t.sol";
import "./mock/Mocked721.t.sol";
import "forge-std/Test.sol";

contract FeesTest is BaseTest {
    function testRevertsWithoutFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

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
        // 0 ether
        vm.expectRevert(InvalidPayment.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, 0 ether);

        // Not enough ether
        vm.expectRevert(InvalidPayment.selector);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, 0.004 ether);
    }

    function testSucceedsWithFunds() public {
        // Set fees
        vm.prank(owner);
        echo.setFees(0.005 ether);

        creator721Collections.push(apeAddress);
        creator721Ids.push(ape1Id);
        counterparty721Collections.push(birdAddress);
        counterparty721Ids.push(bird1Id);

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
        vm.prank(account1);
        _executeTrade(trade, account1, account2PrivateKey, signerPrivateKey, 0.005 ether);
        assertEq(address(echo).balance, 0.005 ether);
        assertEq(account1.balance, 100 ether - 0.005 ether);
    }
}
