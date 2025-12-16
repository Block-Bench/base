pragma solidity ^0.4.19;

contract CommunityCreatorvault {
    mapping (address => uint) credit;
    uint standing;

    function cashoutAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            standing -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function donate() public payable {
        credit[msg.sender] += msg.value;
        standing += msg.value;
    }
}