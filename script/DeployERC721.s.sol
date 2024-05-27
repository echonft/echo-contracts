// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../test/mock/Mocked721.sol";

contract DeployNFT is Script {
    // Exclude from coverage report
    function test() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address gab = address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09);
        address jf = address(0x1E3918dD44F427F056be6C8E132cF1b5F42de59E);

        Mocked721WithSuffix CBC = new Mocked721WithSuffix({name: "Creepz by OVERLORD", symbol: "CBC"});
        CBC.setBaseURI("ipfs://QmVRsXpYYp3qALoxjYUfNZAA6A28P86REKkoqadoXM5tLn/");

        Mocked721 BAYC = new Mocked721({name: "BoredApeYachtClub", symbol: "BAYC"});
        BAYC.setBaseURI("ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/");

        Mocked721 SORA = new Mocked721({name: "Sora's Dreamworld", symbol: "Sora"});
        SORA.setBaseURI("https://sorasdreamworld.io/tokens/");

        Mocked721 MAYC = new Mocked721({name: "MutantApeYachtClub", symbol: "MAYC"});
        MAYC.setBaseURI("https://boredapeyachtclub.com/api/mutants/");

        // Mint NFTs
        //CBC
        CBC.safeMint(gab, 0);
        CBC.safeMint(gab, 1);
        CBC.safeMint(gab, 2);
        CBC.safeMint(gab, 3);
        CBC.safeMint(gab, 4);

        CBC.safeMint(jf, 5);
        CBC.safeMint(jf, 6);
        CBC.safeMint(jf, 7);
        CBC.safeMint(jf, 8);
        CBC.safeMint(jf, 9);

        // BAYC
        BAYC.safeMint(gab, 0);
        BAYC.safeMint(gab, 1);
        BAYC.safeMint(gab, 2);
        BAYC.safeMint(gab, 3);
        BAYC.safeMint(gab, 4);

        BAYC.safeMint(jf, 5);
        BAYC.safeMint(jf, 6);
        BAYC.safeMint(jf, 7);
        BAYC.safeMint(jf, 8);
        BAYC.safeMint(jf, 9);

        // SORA
        SORA.safeMint(gab, 0);
        SORA.safeMint(gab, 1);
        SORA.safeMint(gab, 2);
        SORA.safeMint(gab, 3);
        SORA.safeMint(gab, 4);

        SORA.safeMint(jf, 5);
        SORA.safeMint(jf, 6);
        SORA.safeMint(jf, 7);
        SORA.safeMint(jf, 8);
        SORA.safeMint(jf, 9);

        // MAYC
        MAYC.safeMint(gab, 0);
        MAYC.safeMint(gab, 1);
        MAYC.safeMint(gab, 2);
        MAYC.safeMint(gab, 3);
        MAYC.safeMint(gab, 4);

        MAYC.safeMint(jf, 5);
        MAYC.safeMint(jf, 6);
        MAYC.safeMint(jf, 7);
        MAYC.safeMint(jf, 8);
        MAYC.safeMint(jf, 9);

        vm.stopBroadcast();
    }
}
