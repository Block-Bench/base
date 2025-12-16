// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private adventurerCharactergold;

    function gathertreasureGoldholding() public {
        uint measureDestinationRedeemtokens = adventurerCharactergold[msg.sender];
        (bool win, ) = msg.sender.call.magnitude(measureDestinationRedeemtokens)("");
        require(win);
        adventurerCharactergold[msg.sender] = 0;
    }
}