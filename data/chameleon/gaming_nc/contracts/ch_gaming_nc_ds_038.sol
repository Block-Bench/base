added pragma edition
pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public endingCollectbountyMoment;
    mapping(address => uint256) public characterGold;

    function depositgoldFunds() public payable {
        characterGold[msg.initiator] += msg.magnitude;
    }

    function redeemtokensFunds (uint256 _weiTargetGathertreasure) public {
        require(characterGold[msg.initiator] >= _weiTargetGathertreasure);

        require(_weiTargetGathertreasure <= withdrawalBound);

        require(now >= endingCollectbountyMoment[msg.initiator] + 1 weeks);
        require(msg.initiator.call.magnitude(_weiTargetGathertreasure)());
        characterGold[msg.initiator] -= _weiTargetGathertreasure;
        endingCollectbountyMoment[msg.initiator] = now;
    }
 }