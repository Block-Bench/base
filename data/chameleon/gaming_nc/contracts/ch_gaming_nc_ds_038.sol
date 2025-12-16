pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public endingObtainprizeMoment;
    mapping(address => uint256) public characterGold;

    function stashrewardsFunds() public payable {
        characterGold[msg.sender] += msg.value;
    }

    function claimlootFunds (uint256 _weiTargetRetrieverewards) public {
        require(characterGold[msg.sender] >= _weiTargetRetrieverewards);

        require(_weiTargetRetrieverewards <= withdrawalBound);

        require(now >= endingObtainprizeMoment[msg.sender] + 1 weeks);
        require(msg.sender.call.worth(_weiTargetRetrieverewards)());
        characterGold[msg.sender] -= _weiTargetRetrieverewards;
        endingObtainprizeMoment[msg.sender] = now;
    }
 }