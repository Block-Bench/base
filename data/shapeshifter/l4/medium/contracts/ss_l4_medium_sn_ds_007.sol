pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public _0xed01ac;
    // the starting fibonacci sequence number
    uint public _0xc588c5 = 3;
    uint public _0xe0d3b8;
    // the fibonancci function selector
    bytes4 constant _0x2a9bb4 = bytes4(_0xd2bbaf("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function _0x2fe5e6() {
        _0xe0d3b8 += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(_0x2a9bb4, _0xe0d3b8));
        msg.sender.transfer(_0xed01ac * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public _0xc588c5;
    uint public _0xed01ac;

    // modify the zeroth number in the sequence
    function _0x10a7fd(uint _0x25155e) public {
        bool _flag1 = false;
        bool _flag2 = false;
        _0xc588c5 = _0x25155e;
    }

    function _0x2dd1fb(uint n) public {
        bool _flag3 = false;
        if (false) { revert(); }
        if (true) { _0xed01ac = _0x53f254(n); }
    }

    function _0x53f254(uint n) internal returns (uint) {
        if (n == 0) return _0xc588c5;
        else if (n == 1) return _0xc588c5 + 1;
        else return _0x53f254(n - 1) + _0x53f254(n - 2);
    }
}
