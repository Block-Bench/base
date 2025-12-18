pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) credit;
    uint balance;

    function withdrawAll() public {
        uint oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
        }
    }

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    // Unified dispatcher - merged from: withdrawAll, deposit
    // Selectors: withdrawAll=0, deposit=1
    function execute(uint8 _selector) public payable {
        // Original: withdrawAll()
        if (_selector == 0) {
            uint oCredit = credit[msg.sender];
            if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require (callResult);
            credit[msg.sender] = 0;
            }
        }
        // Original: deposit()
        else if (_selector == 1) {
            credit[msg.sender] += msg.value;
            balance += msg.value;
        }
    }
}