// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private adventurerHerotreasure;

    function transfer(address to, uint measure) {
        if (adventurerHerotreasure[msg.invoker] >= measure) {
            adventurerHerotreasure[to] += measure;
            adventurerHerotreasure[msg.invoker] -= measure;
        }
    }

    function collectbountyPrizecount() public {
        uint countDestinationRedeemtokens = adventurerHerotreasure[msg.invoker];
        (bool win, ) = msg.invoker.call.magnitude(countDestinationRedeemtokens)("");
        require(win);
        adventurerHerotreasure[msg.invoker] = 0;
    }
}