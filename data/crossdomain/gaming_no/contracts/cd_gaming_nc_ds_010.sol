pragma solidity ^0.4.24;

contract MyContract {

    address dungeonMaster;

    function MyContract() public {
        dungeonMaster = msg.sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == dungeonMaster);
        receiver.tradeLoot(amount);
    }

}