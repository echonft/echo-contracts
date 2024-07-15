// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "../src/EchoBlast.sol";
import "./mock/YieldMock.sol";

abstract contract BaseTestBlast is Test {
    address public constant owner = address(1313);
    address public constant account1 = address(1337);
    EchoBlast public echoBlast;

    function setUp() public {
        vm.createSelectFork("https://sepolia.blast.io");
        // Deploy mock of the precompile
        YieldMock yieldMock = new YieldMock();
        // Set mock bytecode to the expected precompile address
        vm.etch(0x0000000000000000000000000000000000000100, address(yieldMock).code);

        // Fund accounts
        vm.deal(account1, 100 ether);
        echoBlast =
            new EchoBlast({owner: owner, blastPointsAddress: address(0x2fc95838c71e76ec69ff817983BFf17c710F34E0)});
    }
}
