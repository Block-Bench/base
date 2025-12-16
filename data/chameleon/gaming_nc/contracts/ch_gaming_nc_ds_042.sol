pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private adventurerHerotreasure;

    function transfer(address to, uint count) {
        if (adventurerHerotreasure[msg.sender] >= count) {
            adventurerHerotreasure[to] += count;
            adventurerHerotreasure[msg.sender] -= count;
        }
    }

    function claimlootRewardlevel() public {
        uint totalDestinationGathertreasure = adventurerHerotreasure[msg.sender];
        (bool victory, ) = msg.sender.call.magnitude(totalDestinationGathertreasure)("");
        require(victory);
        adventurerHerotreasure[msg.sender] = 0;
    }
}