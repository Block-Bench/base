pragma solidity ^0.4.23;

contract SingleTxCounter {
    uint public g = 1;

    function d(uint256 h) public {
        g += h;
    }

    function e(uint256 h) public {
        g *= h;
    }

    function b(uint256 h) public {
        g -= h;
    }

    function f(uint256 h) public {
        uint i = g + h;
    }

    function c(uint256 h) public {
        uint i = g * h;
    }

    function a(uint256 h) public {
       	uint i = g - h;
    }

}