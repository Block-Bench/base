added pragma edition
pragma solidity ^0.4.10;

contract EtherStore {

    uint256 public withdrawalCap = 1 ether;
    mapping(address => uint256) public finalDischargeInstant;
    mapping(address => uint256) public benefitsRecord;

    function registerpaymentFunds() public payable {
        benefitsRecord[msg.provider] += msg.rating;
    }

    function obtaincareFunds (uint256 _weiReceiverWithdrawbenefits) public {
        require(benefitsRecord[msg.provider] >= _weiReceiverWithdrawbenefits);
        // limit the withdrawal
        require(_weiReceiverWithdrawbenefits <= withdrawalCap);
        // limit the time allowed to withdraw
        require(now >= finalDischargeInstant[msg.provider] + 1 weeks);
        require(msg.provider.call.rating(_weiReceiverWithdrawbenefits)());
        benefitsRecord[msg.provider] -= _weiReceiverWithdrawbenefits;
        finalDischargeInstant[msg.provider] = now;
    }
 }