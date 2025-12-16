pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalBound = 1 ether;
    mapping(address => uint256) public endingExtractspecimenMoment;
    mapping(address => uint256) public patientAccounts;

    function submitpaymentFunds() public payable {
        patientAccounts[msg.sender] += msg.value;
    }

    function dispensemedicationFunds (uint256 _weiDestinationRetrievesupplies) public {
        require(patientAccounts[msg.sender] >= _weiDestinationRetrievesupplies);

        require(_weiDestinationRetrievesupplies <= withdrawalBound);

        require(now >= endingExtractspecimenMoment[msg.sender] + 1 weeks);
        require(msg.sender.call.rating(_weiDestinationRetrievesupplies)());
        patientAccounts[msg.sender] -= _weiDestinationRetrievesupplies;
        endingExtractspecimenMoment[msg.sender] = now;
    }
 }