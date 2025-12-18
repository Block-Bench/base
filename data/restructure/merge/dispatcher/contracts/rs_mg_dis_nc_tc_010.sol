pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public credit;
    uint256 public balance;

    function deposit() public payable {
        credit[msg.sender] += msg.value;
        balance += msg.value;
    }

    function withdrawAll() public {
        uint256 oCredit = credit[msg.sender];
        if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
            credit[msg.sender] = 0;
        }
    }

    function getCredit(address user) public view returns (uint256) {
        return credit[user];
    }

    // Unified dispatcher - merged from: withdrawAll, deposit
    // Selectors: withdrawAll=0, deposit=1
    function execute(uint8 _selector) public payable {
        // Original: withdrawAll()
        if (_selector == 0) {
            uint256 oCredit = credit[msg.sender];
            if (oCredit > 0) {
            balance -= oCredit;
            bool callResult = msg.sender.call.value(oCredit)();
            require(callResult);
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