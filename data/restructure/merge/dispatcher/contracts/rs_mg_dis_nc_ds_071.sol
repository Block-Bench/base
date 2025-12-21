pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public depositsCount;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function withdrawAll() public onlyOwner {
        withdraw(address(this).balance);
    }

    function withdraw(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function sendMoney(address _target, uint _value) public onlyOwner {
        _target.call.value(_value)();
    }

    // Unified dispatcher - merged from: sendMoney, withdrawAll, withdraw
    // Selectors: sendMoney=0, withdrawAll=1, withdraw=2
    function execute(uint8 _selector, address _target, uint _value) public {
        // Original: sendMoney()
        if (_selector == 0) {
            _target.call.value(_value)();
        }
        // Original: withdrawAll()
        else if (_selector == 1) {
            withdraw(address(this).balance);
        }
        // Original: withdraw()
        else if (_selector == 2) {
            msg.sender.transfer(_value);
        }
    }
}