// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Echo.sol";

contract DeployEcho is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();
        new Echo({
            owner: address(0x89eb616B4443783c160E7Cd82E56bfc66A545CeF),
            signer: address(0x89eb616B4443783c160E7Cd82E56bfc66A545CeF)
        });

        vm.stopBroadcast();
    }
}
