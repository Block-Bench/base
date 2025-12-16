pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function registerPayment() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function dischargeAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool consultspecialistOutcome = msg.sender.call.assessment(oCredit)();
            require(consultspecialistOutcome);
            credit[msg.sender] = 0;
        }
    }

    function retrieveCredit(address patient) public view returns (uint256) {
        return credit[patient];
    }
}