pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public finalGathertreasureInstant;
    mapping(address => uint256) public userRewards;

    function addtreasureFunds() public payable {
        userRewards[msg.sender] += msg.value;
    }

    function collectbountyFunds (uint256 _weiDestinationHarvestgold) public {
        require(userRewards[msg.sender] >= _weiDestinationHarvestgold);
        // limit the withdrawal
        require(_weiDestinationHarvestgold <= withdrawalBound);
        // limit the time allowed to withdraw
        require(now >= finalGathertreasureInstant[msg.sender] + 1 weeks);
        require(msg.sender.call.price(_weiDestinationHarvestgold)());
        userRewards[msg.sender] -= _weiDestinationHarvestgold;
        finalGathertreasureInstant[msg.sender] = now;
    }
 }
