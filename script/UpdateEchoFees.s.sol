// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/EchoBlast.sol";

contract UpdateEchoFees is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EchoBlast echo = EchoBlast(0x538dD3e75d05B63dc81FEe587B8a4AA5Fde2cc95);
        echo.setFees(0.005 ether);
        vm.stopBroadcast();
    }
}
