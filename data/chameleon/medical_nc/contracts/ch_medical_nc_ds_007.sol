pragma solidity ^0.4.22;

contract FibonacciBenefits {

    address public fibonacciLibrary;

    uint public evaluatedFibNumber;

    uint public begin = 3;
    uint public withdrawalTally;

    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function dispenseMedication() {
        withdrawalTally += 1;


        require(fibonacciLibrary.delegatecall(fibSig, withdrawalTally));
        msg.sender.transfer(evaluatedFibNumber * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}


contract FibonacciLib {

    uint public begin;
    uint public evaluatedFibNumber;


    function groupBegin(uint _start) public {
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