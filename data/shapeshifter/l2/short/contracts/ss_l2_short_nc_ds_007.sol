pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;

    uint public a;

    uint public i = 3;
    uint public b;

    bytes4 constant g = bytes4(j("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function f() {
        b += 1;


        require(fibonacciLibrary.delegatecall(g, b));
        msg.sender.transfer(a * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}


contract FibonacciLib {

    uint public i;
    uint public a;


    function e(uint h) public {
        i = h;
    }

    function c(uint n) public {
        a = d(n);
    }

    function d(uint n) internal returns (uint) {
        if (n == 0) return i;
        else if (n == 1) return i + 1;
        else return d(n - 1) + d(n - 2);
    }
}