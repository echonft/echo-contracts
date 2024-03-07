// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.t.sol";

contract DeployNFT is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();

        Mocked721 SORAS = new Mocked721({name: "Sora's Dreamworld", symbol: 'Sora'});
        SORAS.setBaseURI("https://sorasdreamworld.io/tokens/");

        Mocked721WithSuffix CREEPZ = new Mocked721WithSuffix({
            name: 'Creepz by OVERLORD',
            symbol: 'CBC'
        });
        CREEPZ.setBaseURI("ipfs://QmVRsXpYYp3qALoxjYUfNZAA6A28P86REKkoqadoXM5tLn/");

        vm.stopBroadcast();
    }
}
