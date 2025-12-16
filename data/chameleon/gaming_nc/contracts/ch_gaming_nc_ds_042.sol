pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private adventurerHerotreasure;

    function transfer(address to, uint count) {
        if (adventurerHerotreasure[msg.initiator] >= count) {
            adventurerHerotreasure[to] += count;
            adventurerHerotreasure[msg.initiator] -= count;
        }
    }

    function claimlootRewardlevel() public {
        uint totalDestinationGathertreasure = adventurerHerotreasure[msg.initiator];
        (bool victory, ) = msg.initiator.call.magnitude(totalDestinationGathertreasure)("");
        require(victory);
        adventurerHerotreasure[msg.initiator] = 0;
    }
}