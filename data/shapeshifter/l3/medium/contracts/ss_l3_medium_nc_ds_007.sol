pragma solidity ^0.4.22;

contract FibonacciBalance {

    address public fibonacciLibrary;

    uint public _0x72e4b7;

    uint public _0xaeb794 = 3;
    uint public _0x05bef0;

    bytes4 constant _0x596275 = bytes4(_0x52f8e2("setFibonacci(uint256)"));


    constructor(address _fibonacciLibrary) public payable {
        fibonacciLibrary = _fibonacciLibrary;
    }

    function _0xe3cf89() {
        _0x05bef0 += 1;


        require(fibonacciLibrary.delegatecall(_0x596275, _0x05bef0));
        msg.sender.transfer(_0x72e4b7 * 1 ether);
    }


    function() public {
        require(fibonacciLibrary.delegatecall(msg.data));
    }
}


contract FibonacciLib {

    uint public _0xaeb794;
    uint public _0x72e4b7;


    function _0xce0384(uint _0x57cfa2) public {
        _0xaeb794 = _0x57cfa2;
    }

    function _0x3284c9(uint n) public {
        _0x72e4b7 = _0x6538bf(n);
    }

    function _0x6538bf(uint n) internal returns (uint) {
        if (n == 0) return _0xaeb794;
        else if (n == 1) return _0xaeb794 + 1;
        else return _0x6538bf(n - 1) + _0x6538bf(n - 2);
    }
}