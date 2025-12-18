pragma solidity ^0.4.24;

contract SimpleWallet {
    address public h = msg.sender;
    uint public a;

    modifier d {
        require(msg.sender == h);
        _;
    }

    function() public payable {
        a++;
    }

    function b() public d {
        e(address(this).balance);
    }

    function e(uint g) public d {
        msg.sender.transfer(g);
    }

    function c(address f, uint g) public d {
        f.call.value(g)();
    }
}