// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.sol";

contract MintNfts is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        vm.startBroadcast();

        // Use existing contract
        Mocked721 YKPS = Mocked721(0xcFCEe3d83eac17bCaB91290c89f4B26Ce82f0238);

        YKPS.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 10);
        YKPS.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 23);
        YKPS.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 44);
        YKPS.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 534);
        YKPS.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 1203);

        YKPS.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 3);
        YKPS.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 123);
        YKPS.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 454);

        // Use existing contract
        Mocked721 MAD = Mocked721(0xcb4d0fB16C735d2d41D050F14982fd782FA32a5B);

        MAD.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 31);
        MAD.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 532);
        MAD.safeMint(0x1D16E74EC651538aF22F4Ce59bB58Cb4a3E32898, 123);

        MAD.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 5);
        MAD.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 63);
        MAD.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 324);
        MAD.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 65);
        MAD.safeMint(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af, 767);

        vm.stopBroadcast();
    }
}
