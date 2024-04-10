// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "contracts/EchoCrossChain.sol";
import "forge-std/Script.sol";

contract DeployEchoCrossChain is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();
        new EchoCrossChain({
            owner: address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09),
            wormhole: address(0x4a8bc80Ed5a4067f1CCf107057b8270E0cC11A78),
            chainId: 2,
            wormholeFinality: 1
        });

        vm.stopBroadcast();
    }
}
