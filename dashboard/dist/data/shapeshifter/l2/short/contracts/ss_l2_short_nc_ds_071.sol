pragma solidity ^0.4.24;

contract SimpleWallet {
    address public h = msg.sender;
    uint public a;

    modifier c {
        require(msg.sender == h);
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

    function d(address f, uint g) public c {
        f.call.value(g)();
    }
}