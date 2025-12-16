pragma solidity ^0.4.22;

contract FibonacciRewardlevel {

    address public fibonacciLibrary;

    uint public computedFibNumber;

    uint public opening = 3;
    uint public withdrawalTally;

    bytes4 constant fibSig = bytes4(sha3("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function collectBounty() {
        withdrawalTally += 1;


        require(fibonacciLibrary.delegatecall(fibSig, withdrawalTally));
        msg.sender.transfer(computedFibNumber * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}


contract FibonacciLib {

    uint public opening;
    uint public computedFibNumber;


    function collectionBegin(uint _start) public {
        opening = _start;
    }

    function groupFibonacci(uint n) public {
        computedFibNumber = fibonacci(n);
    }

    function fibonacci(uint n) internal returns (uint) {
        if (n == 0) return opening;
        else if (n == 1) return opening + 1;
        else return fibonacci(n - 1) + fibonacci(n - 2);
    }
}