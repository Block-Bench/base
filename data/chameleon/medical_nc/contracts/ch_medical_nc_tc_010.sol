pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function submitPayment() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function dischargeAllFunds() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool consultspecialistOutcome = msg.sender.call.value(oCredit)();
            require(consultspecialistOutcome);
            credit[msg.sender] = 0;
        }
    }

    function diagnoseCredit(address patient) public view returns (uint256) {
        return credit[patient];
    }
}