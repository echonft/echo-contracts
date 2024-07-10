// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Echo.sol";
import "../lib/blast/IBlast.sol";
import "../lib/blast/IBlastPoints.sol";

contract EchoBlast is Echo {
    IBlast private constant BLAST = IBlast(0x4300000000000000000000000000000000000002);

    constructor(address owner, address blastPointsAddress) Echo(owner) {
        IBlastPoints(blastPointsAddress).configurePointsOperator(owner);
        BLAST.configureAutomaticYield();
        BLAST.configureClaimableGas();
    }

    function claimGas() external onlyOwner {
        BLAST.claimMaxGas(address(this), msg.sender);
    }
}
