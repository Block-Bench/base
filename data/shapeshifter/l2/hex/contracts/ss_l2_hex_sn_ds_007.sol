pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;
    // the current fibonacci number to withdraw
    uint public _0x251704;
    // the starting fibonacci sequence number
    uint public _0xa779a2 = 3;
    uint public _0x9698ff;
    // the fibonancci function selector
    bytes4 constant _0xdf87ef = bytes4(_0x0a7360("setFibonacci(uint256)"));

    // constructor - loads the contract with ether
    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function _0x5d516a() {
        _0x9698ff += 1;
        // calculate the fibonacci number for the current withdrawal user
        // this sets calculatedFibNumber
        require(fibonacciLibrary.delegatecall(_0xdf87ef, _0x9698ff));
        msg.sender.transfer(_0x251704 * 1 ether);
    }

    // allow users to call fibonacci library functions
    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}

// library contract - calculates fibonacci-like numbers;
contract FibonacciLib {
    // initializing the standard fibonacci sequence;
    uint public _0xa779a2;
    uint public _0x251704;

    // modify the zeroth number in the sequence
    function _0x18804b(uint _0xe2a991) public {
        _0xa779a2 = _0xe2a991;
    }

    function _0xc47bae(uint n) public {
        _0x251704 = _0x2fda18(n);
    }

    function _0x2fda18(uint n) internal returns (uint) {
        if (n == 0) return _0xa779a2;
        else if (n == 1) return _0xa779a2 + 1;
        else return _0x2fda18(n - 1) + _0x2fda18(n - 2);
    }
}
