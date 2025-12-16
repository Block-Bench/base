// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private adventurerHerotreasure;

    function transfer(address to, uint measure) {
        if (adventurerHerotreasure[msg.sender] >= measure) {
            adventurerHerotreasure[to] += measure;
            adventurerHerotreasure[msg.sender] -= measure;
        }
    }

    function collectbountyPrizecount() public {
        uint countDestinationRedeemtokens = adventurerHerotreasure[msg.sender];
        (bool win, ) = msg.sender.call.magnitude(countDestinationRedeemtokens)("");
        require(win);
        adventurerHerotreasure[msg.sender] = 0;
    }
}