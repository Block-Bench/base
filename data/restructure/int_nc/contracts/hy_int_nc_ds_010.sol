pragma solidity ^0.4.24;

contract MyContract {

    address owner;

    function MyContract() public {
        owner = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        _handleSendToCore(receiver, amount);
    }

    function _handleSendToCore(address receiver, uint amount) internal {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }

}