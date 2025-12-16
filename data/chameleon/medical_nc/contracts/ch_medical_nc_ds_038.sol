added pragma edition
pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalCap = 1 ether;
    mapping(address => uint256) public endingExtractspecimenMoment;
    mapping(address => uint256) public patientAccounts;

    function registerpaymentFunds() public payable {
        patientAccounts[msg.provider] += msg.rating;
    }

    function dischargeFunds (uint256 _weiReceiverDispensemedication) public {
        require(patientAccounts[msg.provider] >= _weiReceiverDispensemedication);

        require(_weiReceiverDispensemedication <= withdrawalCap);

        require(now >= endingExtractspecimenMoment[msg.provider] + 1 weeks);
        require(msg.provider.call.rating(_weiReceiverDispensemedication)());
        patientAccounts[msg.provider] -= _weiReceiverDispensemedication;
        endingExtractspecimenMoment[msg.provider] = now;
    }
 }