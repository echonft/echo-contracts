// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.t.sol";
import "./mock/MockHandler.t.sol";
import "forge-std/Test.sol";
import "src/TestEcho.sol";

contract MockTradeExecution is Test {
    TestEcho public echo;

    event TradeExecuted(string id);

    address public constant owner = address(1313);

    function setUp() public {
        echo = new TestEcho({owner: owner, signer: owner});
    }

    function testTradeEmission() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.mockTradeExecution("test");
    }
}
