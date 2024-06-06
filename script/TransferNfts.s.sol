// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.sol";

contract TransferNfts is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        console.log(block.chainid);
        uint256 work2PrivateKey = vm.envUint("WORK2_PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address work2 = vm.addr(work2PrivateKey);
        Mocked721 MAYC = Mocked721(0x4B8c2CE024D1cC1CFaE7FaA4A162bBfeAdBaEB41);
        MAYC.transferFrom(deployer, work2, 3);
        vm.stopBroadcast();

        vm.startBroadcast(work2PrivateKey);
        MAYC.safeTransferFrom(work2, deployer, 3);
        vm.stopBroadcast();
    }
}
