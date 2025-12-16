pragma solidity ^0.4.22;

contract FibonacciBalance {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


    address public fibonacciLibrary;

    uint public calculatedFibNumber;

    uint public start = 3;
    uint public withdrawalCounter;

    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function withdraw() {
        withdrawalCounter += 1;


        require(fibonacciLibrary.delegatecall(fibSig, withdrawalCounter));
        msg.sender.transfer(calculatedFibNumber * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}


contract FibonacciLib {

    uint public start;
    uint public calculatedFibNumber;


    function setStart(uint _start) public onlyOwner {
        start = _start;
    }

    function setFibonacci(uint n) public onlyOwner {
        calculatedFibNumber = fibonacci(n);
    }

    function fibonacci(uint n) internal returns (uint) {
        if (n == 0) return start;
        else if (n == 1) return start + 1;
        else return fibonacci(n - 1) + fibonacci(n - 2);
    }
}