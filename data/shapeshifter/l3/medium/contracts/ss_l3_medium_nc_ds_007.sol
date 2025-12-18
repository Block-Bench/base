pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;

    uint public _0x64b177;

    uint public _0x27f4d3 = 3;
    uint public _0x898d82;

    bytes4 constant _0xe6580e = bytes4(_0xa64405("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function _0xe0ca4f() {
        _0x898d82 += 1;


        require(fibonacciLibrary.delegatecall(_0xe6580e, _0x898d82));
        msg.sender.transfer(_0x64b177 * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}


contract FibonacciLib {

    uint public _0x27f4d3;
    uint public _0x64b177;


    function _0x88b54b(uint _0xa3a899) public {
        _0x27f4d3 = _0xa3a899;
    }

    function _0xf24ff2(uint n) public {
        _0x64b177 = _0x09ca8a(n);
    }

    function _0x09ca8a(uint n) internal returns (uint) {
        if (n == 0) return _0x27f4d3;
        else if (n == 1) return _0x27f4d3 + 1;
        else return _0x09ca8a(n - 1) + _0x09ca8a(n - 2);
    }
}