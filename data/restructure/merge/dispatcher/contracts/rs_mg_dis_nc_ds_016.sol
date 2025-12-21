pragma solidity ^0.4.24;

 contract Wallet {
     address creator;

     mapping(address => uint256) balances;

     constructor() public {
         creator = msg.sender;
     }

     function deposit() public payable {
         assert(balances[msg.sender] + msg.value > balances[msg.sender]);
         balances[msg.sender] += msg.value;
     }

     function withdraw(uint256 amount) public {
         require(amount >= balances[msg.sender]);
         msg.sender.transfer(amount);
         balances[msg.sender] -= amount;
     }


     function migrateTo(address to) public {
         require(creator == msg.sender);
         to.transfer(this.balance);
     }

 
    // Unified dispatcher - merged from: withdraw, deposit, migrateTo
    // Selectors: withdraw=0, deposit=1, migrateTo=2
    function execute(uint8 _selector, address to, uint256 amount) public payable {
        // Original: withdraw()
        if (_selector == 0) {
            require(amount >= balances[msg.sender]);
            msg.sender.transfer(amount);
            balances[msg.sender] -= amount;
        }
        // Original: deposit()
        else if (_selector == 1) {
            assert(balances[msg.sender] + msg.value > balances[msg.sender]);
            balances[msg.sender] += msg.value;
        }
        // Original: migrateTo()
        else if (_selector == 2) {
            require(creator == msg.sender);
            to.transfer(this.balance);
        }
    }
}