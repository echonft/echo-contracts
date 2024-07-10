// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../../src/EchoBlast.sol";
import "../../test/utils/OfferUtils.sol";

contract CreateTestOffer is Script, OfferUtils {
    // Exclude from coverage report
    function test() public override {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        EchoBlast echo = EchoBlast(0xF37c2C531a6ffEBb8d3EdCF34e54b0E26047dA4C);

        address sender = address(0x213bE2f484Ab480db4f18b0Fe4C38e1C25877f09);
        address receiver = address(0x20F039821DE7Db6f543c7C07D419800Eb9Bd01Af);
        address NFT = address(0x43bE93945E168A205D708F1A41A124fA302e1f76);
        uint256 expiration = 1818917576;
        address[] memory senderTokenAddresses = new address[](1);
        senderTokenAddresses[0] = NFT;
        uint256[] memory senderTokenIds = new uint256[](1);
        senderTokenIds[0] = 2;
        uint256[] memory senderTokenAmounts = new uint256[](1);
        senderTokenAmounts[0] = 0;
        address[] memory receiverTokenAddresses = new address[](1);
        receiverTokenAddresses[0] = NFT;
        uint256[] memory receiverTokenIds = new uint256[](1);
        receiverTokenIds[0] = 1;
        uint256[] memory receiverTokenAmounts = new uint256[](1);
        receiverTokenAmounts[0] = 0;

        Offer memory offer = generateOffer(
            sender,
            senderTokenAddresses,
            senderTokenIds,
            senderTokenAmounts,
            block.chainid,
            receiver,
            receiverTokenAddresses,
            receiverTokenIds,
            receiverTokenAmounts,
            block.chainid,
            expiration,
            OfferState.OPEN
        );
        echo.createOffer(offer);

        vm.stopBroadcast();
    }
}
