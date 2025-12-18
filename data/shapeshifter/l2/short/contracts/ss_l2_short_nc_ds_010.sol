pragma solidity ^0.4.24;

contract MyContract {

    address d;

    function MyContract() public {
        d = msg.sender;
    }

    function b(address a, uint c) public {
        require(tx.origin == d);
        a.transfer(c);
    }

}