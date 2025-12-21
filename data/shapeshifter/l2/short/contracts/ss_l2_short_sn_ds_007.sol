pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public a;
    // the starting fibonacci sequence number
    uint public i = 3;
    uint public b;
    // the fibonancci function selector
    bytes4 constant h = bytes4(j("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function f() {
        b += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(h, b));
        msg.sender.transfer(a * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public i;
    uint public a;

    // modify the zeroth number in the sequence
    function e(uint g) public {
        i = g;
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
