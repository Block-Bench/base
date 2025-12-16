// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private adventurerCharactergold;

    function gathertreasureGoldholding() public {
        uint measureDestinationRedeemtokens = adventurerCharactergold[msg.caster];
        (bool win, ) = msg.caster.call.magnitude(measureDestinationRedeemtokens)("");
        require(win);
        adventurerCharactergold[msg.caster] = 0;
    }
}