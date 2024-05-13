// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.sol";

contract DeployNFT is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();

        Mocked721 YKPS = new Mocked721({name: "Kanpai Panda", symbol: "YKPS"});
        YKPS.setBaseURI("https://prod.kanpaidev.com/api/token/");

        Mocked721WithSuffix MAD = new Mocked721WithSuffix({name: "Mad Lads", symbol: "MAD"});
        MAD.setBaseURI("https://madlads.s3.us-west-2.amazonaws.com/json/");

        vm.stopBroadcast();
    }
}
