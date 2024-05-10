// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../../src/escrow/EscrowHandler.sol";

contract MockedHandler is EscrowHandler {
    // Exclude from coverage report
    function test() public {}
}
