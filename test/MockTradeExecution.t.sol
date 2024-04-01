// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./mock/Mocked721.t.sol";
import "./mock/MockHandler.t.sol";
import "./utils/Constants.sol";
import "forge-std/Test.sol";
import "src/TestEcho.sol";

// @dev Only used to test the TestEcho contract which is a simple contract to test signatures
contract MockTradeExecution is Test, Constants {
    TestEcho public echo;

    event TradeExecuted(string id);

    uint256 public constant ownerPrivateKey = 0xB0B;
    address public owner;

    function setUp() public {
        owner = vm.addr(ownerPrivateKey);
        echo = new TestEcho({owner: owner, signer: owner});
    }

    // @dev Sign the signature with the private key. This is simulating the backend signing
    function _signSignature(Signature memory signature, uint256 privateKey)
        internal
        view
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        bytes32 hashStruct = keccak256(abi.encode(SIGNATURE_TYPEHASH, signature.v, signature.r, signature.s));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", echo.domainSeparator(), hashStruct));
        (v, r, s) = vm.sign(privateKey, digest);
    }

    function testTradeEmission() public {
        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.mockTradeExecution("test");
    }

    function testSigner() public {
        (uint8 v, bytes32 r, bytes32 s) = _signSignature(mockSignature, ownerPrivateKey);

        vm.prank(owner);
        vm.expectEmit(true, true, true, true);
        emit TradeExecuted("test");
        echo.executeTrade(v, r, s, mockSignature);
    }

    function testWrongSigner() public {
        (uint8 v, bytes32 r, bytes32 s) = _signSignature(mockSignature, 0xA11CE);

        vm.prank(owner);
        vm.expectRevert(InvalidSigner.selector);
        echo.executeTrade(v, r, s, mockSignature);
    }
}
