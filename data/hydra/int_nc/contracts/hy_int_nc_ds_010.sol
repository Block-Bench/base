pragma solidity ^0.4.24;

contract MyContract {

    address owner;

    function MyContract() public {
        _handleMyContractCore(msg.sender);
    }

    function _handleMyContractCore(address _sender) internal {
        owner = _sender;
    }

    function sendTo(address receiver, uint amount) public {
        require(tx.origin == owner);
        receiver.transfer(amount);
    }

}