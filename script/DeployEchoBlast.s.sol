// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/EchoBlast.sol";
import "../test/mock/YieldMock.sol";

contract DeployEchoBlast is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.createSelectFork(vm.envString("BLAST_SEPOLIA_RPC_URL"));
        // Deploy mock of the precompile
        YieldMock yieldMock = new YieldMock();
        // Set mock bytecode to the expected precompile address
        vm.etch(0x0000000000000000000000000000000000000100, address(yieldMock).code);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        new EchoBlast({
            owner: address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09),
            blastPointsAddress: address(0x2fc95838c71e76ec69ff817983BFf17c710F34E0)
        });

        vm.stopBroadcast();
    }
}
