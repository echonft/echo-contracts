// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/EchoCC.sol";

contract TestEchoCC is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();

        // Use existing contract
        EchoCC echo = EchoCC(0x7DA16cd402106Adaf39092215DbB54092b80B6E6);

        echo.registerEmitter(1, bytes32("echoSolanaAddress"));
        echo.sendMessage("test");

        vm.stopBroadcast();
    }
}
