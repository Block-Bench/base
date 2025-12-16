pragma solidity ^0.4.19;

contract CommunityBenefitvault {
    mapping (address => uint) credit;
    uint allowance;

    function receivepayoutAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            allowance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function fundAccount() public payable {
        credit[msg.sender] += msg.value;
        allowance += msg.value;
    }
}