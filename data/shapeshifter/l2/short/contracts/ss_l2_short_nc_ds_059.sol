pragma solidity ^0.4.24;

contract SimpleWallet {
    address public i = msg.sender;
    uint public a;

    modifier c {
        require(msg.sender == i);
        _;
    }

    function() public payable {
        a++;
    }

    function b() public c {
        e(address(this).balance);
    }

    function e(uint g) public c {
        msg.sender.transfer(g);
    }

    function d(address f, uint g, bytes h) public c {
        f.call.value(g)(h);
    }
}