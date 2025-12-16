pragma solidity ^0.4.22;

contract FibonacciGoldholding {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public derivedFibNumber;
    // the starting fibonacci sequence number
    uint public opening = 3;
    uint public withdrawalCount;
    // the fibonancci function selector
    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function gatherTreasure() {
        withdrawalCount += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(fibSig, withdrawalCount));
        msg.sender.transfer(derivedFibNumber * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public opening;
    uint public derivedFibNumber;

    // modify the zeroth number in the sequence
    function groupOpening(uint _start) public {
        opening = _start;
    }

    function groupFibonacci(uint n) public {
        derivedFibNumber = fibonacci(n);
    }

    function fibonacci(uint n) internal returns (uint) {
        if (n == 0) return opening;
        else if (n == 1) return opening + 1;
        else return fibonacci(n - 1) + fibonacci(n - 2);
    }
}
