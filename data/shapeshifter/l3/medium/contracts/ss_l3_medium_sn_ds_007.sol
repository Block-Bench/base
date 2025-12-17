pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public _0x4fb496;
    // the starting fibonacci sequence number
    uint public _0x4b6f01 = 3;
    uint public _0xc23c3a;
    // the fibonancci function selector
    bytes4 constant _0x593736 = bytes4(_0x69df29("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function _0x6d5e20() {
        _0xc23c3a += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(_0x593736, _0xc23c3a));
        msg.sender.transfer(_0x4fb496 * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public _0x4b6f01;
    uint public _0x4fb496;

    // modify the zeroth number in the sequence
    function _0xf60b6f(uint _0xe6c052) public {
        _0x4b6f01 = _0xe6c052;
    }

    function _0x431bd1(uint n) public {
        _0x4fb496 = _0xa48df7(n);
    }

    function _0xa48df7(uint n) internal returns (uint) {
        if (n == 0) return _0x4b6f01;
        else if (n == 1) return _0x4b6f01 + 1;
        else return _0xa48df7(n - 1) + _0xa48df7(n - 2);
    }
}
