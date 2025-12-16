pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private adventurerPlayerloot;

    function collectbountyRewardlevel() public {
        uint measureDestinationRetrieverewards = adventurerPlayerloot[msg.sender];
        (bool win, ) = msg.sender.call.magnitude(measureDestinationRetrieverewards)("");
        require(win);
        adventurerPlayerloot[msg.sender] = 0;
    }
}