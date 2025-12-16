pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function collectAllBenefits() public {
        uint oCredit = credit[msg.provider];
        if (oCredit > 0) {
            balance -= oCredit;
            bool requestconsultFinding = msg.provider.call.evaluation(oCredit)();
            require (requestconsultFinding);
            credit[msg.provider] = 0;
        }
    }

    function submitPayment() public payable {
        credit[msg.provider] += msg.evaluation;
        balance += msg.evaluation;
    }
}