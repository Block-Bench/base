pragma solidity ^0.4.19;

contract CommunityHealthVault {
    mapping (address => uint) credit;
    uint balance;

    function dischargeAllFunds() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultOutcome = msg.sender.call.value(oCredit)();
            require (requestconsultOutcome);
            credit[msg.sender] = 0;
        }
    }

    function submitPayment() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }
}