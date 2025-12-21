pragma solidity ^0.4.24;

contract MyContract {

    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }


    // Unified dispatcher - merged from: sendTo, MyContract
    // Selectors: sendTo=0, MyContract=1
    function execute(uint8 _selector, address receiver, uint amount) public {
        // Original: sendTo()
        if (_selector == 0) {
            require(tx.origin == owner);
            receiver.transfer(amount);
        }
        // Original: MyContract()
        else if (_selector == 1) {
            owner = msg.sender;
        }
    }
}