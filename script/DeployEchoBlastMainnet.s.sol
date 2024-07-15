// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/EchoBlast.sol";
import "../test/mock/YieldMock.sol";

contract DeployEchoBlastMainnet is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.createSelectFork(vm.envString("BLAST_RPC_URL"));
        // Deploy mock of the precompile
        YieldMock yieldMock = new YieldMock();
        // Set mock bytecode to the expected precompile address
        vm.etch(0x0000000000000000000000000000000000000100, address(yieldMock).code);

        uint256 deployerPrivateKey = vm.envUint("MAINNET_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);
        new EchoBlast({owner: deployer, blastPointsAddress: address(0x2536FE9ab3F511540F2f9e2eC2A805005C3Dd800)});

        vm.stopBroadcast();
    }
}
