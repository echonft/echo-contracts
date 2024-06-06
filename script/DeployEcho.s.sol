// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Echo.sol";

contract DeployEcho is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new Echo({owner: address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09)});

        vm.stopBroadcast();
    }
}
