pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public endingRetrievesuppliesInstant;
    mapping(address => uint256) public benefitsRecord;

    function fundaccountFunds() public payable {
        benefitsRecord[msg.sender] += msg.value;
    }

    function claimcoverageFunds (uint256 _weiReceiverExtractspecimen) public {
        require(benefitsRecord[msg.sender] >= _weiReceiverExtractspecimen);
        // limit the withdrawal
        require(_weiReceiverExtractspecimen <= withdrawalBound);
        // limit the time allowed to withdraw
        require(now >= endingRetrievesuppliesInstant[msg.sender] + 1 weeks);
        require(msg.sender.call.assessment(_weiReceiverExtractspecimen)());
        benefitsRecord[msg.sender] -= _weiReceiverExtractspecimen;
        endingRetrievesuppliesInstant[msg.sender] = now;
    }
 }
