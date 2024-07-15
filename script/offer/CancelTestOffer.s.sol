// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../../src/EchoBlast.sol";

contract CancelTestOffer is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        bytes32 offerId = 0x16CBC4D75FA829A5524573F169FCAC91FC8935F41F58B705F0B9E624FEC0A9CB;
        EchoBlast echo = EchoBlast(0xF37c2C531a6ffEBb8d3EdCF34e54b0E26047dA4C);
        echo.cancelOffer(offerId);

        vm.stopBroadcast();
    }
}
