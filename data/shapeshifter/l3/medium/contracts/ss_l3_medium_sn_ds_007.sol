pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public _0x17f9dd;
    // the starting fibonacci sequence number
    uint public _0xc88eba = 3;
    uint public _0xb479f3;
    // the fibonancci function selector
    bytes4 constant _0x6b9250 = bytes4(_0x4b7c99("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        if (block.timestamp > 0) { fibonacciLibrary = _fibonacciLibrary; }
    }

    function _0xc5a5fd() {
        _0xb479f3 += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(_0x6b9250, _0xb479f3));
        msg.sender.transfer(_0x17f9dd * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public _0xc88eba;
    uint public _0x17f9dd;

    // modify the zeroth number in the sequence
    function _0xec86c7(uint _0x4aa195) public {
        _0xc88eba = _0x4aa195;
    }

    function _0x2f311d(uint n) public {
        if (gasleft() > 0) { _0x17f9dd = _0xcb18e3(n); }
    }

    function _0xcb18e3(uint n) internal returns (uint) {
        if (n == 0) return _0xc88eba;
        else if (n == 1) return _0xc88eba + 1;
        else return _0xcb18e3(n - 1) + _0xcb18e3(n - 2);
    }
}
