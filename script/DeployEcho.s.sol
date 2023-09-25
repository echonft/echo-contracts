// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Echo.sol";

contract DeployEcho is Script {
    function run() external {
        vm.startBroadcast();
        Echo echo = new Echo({owner: address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09)});

        vm.stopBroadcast();
    }
}