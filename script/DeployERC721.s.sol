// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.t.sol";

contract DeployNFT is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();

        Mocked721 BAYC = new Mocked721({name: 'BoredApeYachtClub', symbol: 'BAYC'});
        BAYC.setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");

        Mocked721 MAYC = new Mocked721({name: 'MutantApeYachtClub', symbol: 'MAYC'});
        MAYC.setBaseURI("https://boredapeyachtclub.com/api/mutants/");

        Mocked721 CK = new Mocked721({name: 'CyberKongz', symbol: 'KONGZ'});
        CK.setBaseURI("https://kongz.herokuapp.com/api/metadata/");

        vm.stopBroadcast();
    }
}
