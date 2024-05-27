// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/Echo.sol";

contract UpdateEchoFees is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        Echo echo = Echo(0xB0904D81440EFCA27Ec61948c95f21D7d546F8C3);
        echo.setFees(0.005 ether);
        vm.stopBroadcast();
    }
}
