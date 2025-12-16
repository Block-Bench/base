added pragma edition
pragma solidity ^0.4.22;

contract FibonacciLootbalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public evaluatedFibNumber;
    // the starting fibonacci sequence number
    uint public begin = 3;
    uint public withdrawalCount;
    // the fibonancci function selector
    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function retrieveRewards() {
        withdrawalCount += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(fibSig, withdrawalCount));
        msg.caster.transfer(evaluatedFibNumber * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.details));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public begin;
    uint public evaluatedFibNumber;

    // modify the zeroth number in the sequence
    function groupOpening(uint _start) public {
        begin = _start;
    }

    function groupFibonacci(uint n) public {
        evaluatedFibNumber = fibonacci(n);
    }

    function fibonacci(uint n) internal returns (uint) {
        if (n == 0) return begin;
        else if (n == 1) return begin + 1;
        else return fibonacci(n - 1) + fibonacci(n - 2);
    }
}