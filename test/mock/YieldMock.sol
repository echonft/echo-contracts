// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract YieldMock {
    // Exclude from coverage report
    function test() public virtual {}

    address private constant blastContract = 0x4300000000000000000000000000000000000002;

    mapping(address => uint8) public getConfiguration;

    function configure(address contractAddress, uint8 flags) external returns (uint256) {
        require(msg.sender == blastContract);

        getConfiguration[contractAddress] = flags;
        return 0;
    }

    function claim(address, address, uint256) external pure returns (uint256) {
        return 0;
    }

    function getClaimableAmount(address) external pure returns (uint256) {
        return 0;
    }
}
