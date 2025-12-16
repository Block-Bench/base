added pragma release
pragma solidity ^0.4.22;

contract FibonacciLootbalance {

    address public fibonacciLibrary;

    uint public evaluatedFibNumber;

    uint public begin = 3;
    uint public withdrawalCount;

    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function claimLoot() {
        withdrawalCount += 1;


        require(fibonacciLibrary.delegatecall(fibSig, withdrawalCount));
        msg.invoker.transfer(evaluatedFibNumber * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.info));
    }
}


contract FibonacciLib {

    uint public begin;
    uint public evaluatedFibNumber;


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