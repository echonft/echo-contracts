// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Script.sol";
import "../src/TestEcho.sol";
import "../test/utils/Constants.sol";

contract TestSignerSignature is Script {
    // Exclude from coverage report
    function test() public {}

    function _splitSignature(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
    }

    function run() external {
        vm.startBroadcast();
        // Use existing contract
        TestEcho echo = TestEcho(0x7dfC7f96c967C9e00988D6Bf78da64939B1CC634);

        bytes memory offerSignature =
            hex"b180fe5c8980be7a4bcfb11bc1a113600879da7053b2bedb8984e350d8231221702acd0bb3894f67ebc7d7bc52aefb23f4f0bc96e161e38efb95640016c0f9721c";

        (bytes32 rOffer, bytes32 sOffer, uint8 vOffer) = _splitSignature(offerSignature);
        bytes32 hashStruct = keccak256(abi.encode(SIGNATURE_TYPEHASH, vOffer, rOffer, sOffer));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", echo.domainSeparator(), hashStruct));
        // @dev since we're using an existing contract, we need to use the signer key here.
        // Simply add the proper one and use the script, but make sure it's not committed.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xB0B, digest);
        Signature memory signature = Signature({v: vOffer, r: rOffer, s: sOffer});
        echo.executeTrade(v, r, s, signature);

        vm.stopBroadcast();
    }
}
