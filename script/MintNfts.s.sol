// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.sol";

contract MintNfts is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address minter = address(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af);

        Mocked721 CBC = Mocked721(0xd91303F46C3f4883D9D74c703C15948e5E04E110);
        Mocked721 BAYC = Mocked721(0x43bE93945E168A205D708F1A41A124fA302e1f76);
        Mocked721 SORA = Mocked721(0x07d31999C2BAe29086133A5C93b07a481c5dDaea);
        Mocked721 MAYC = Mocked721(0x4B8c2CE024D1cC1CFaE7FaA4A162bBfeAdBaEB41);

        // Mint NFTs
        //CBC
        CBC.safeMint(minter, 10);
        CBC.safeMint(minter, 11);
        CBC.safeMint(minter, 12);
        CBC.safeMint(minter, 13);
        CBC.safeMint(minter, 14);

        // BAYC
        BAYC.safeMint(minter, 10);
        BAYC.safeMint(minter, 11);
        BAYC.safeMint(minter, 12);
        BAYC.safeMint(minter, 13);
        BAYC.safeMint(minter, 14);

        // SORA
        SORA.safeMint(minter, 10);
        SORA.safeMint(minter, 11);
        SORA.safeMint(minter, 12);
        SORA.safeMint(minter, 13);
        SORA.safeMint(minter, 14);

        // MAYC
        MAYC.safeMint(minter, 10);
        MAYC.safeMint(minter, 11);
        MAYC.safeMint(minter, 12);
        MAYC.safeMint(minter, 13);
        MAYC.safeMint(minter, 14);

        vm.stopBroadcast();
    }
}
