pragma solidity ^0.4.23;

contract SingleTxCounter {
    uint public h = 1;

    function d(uint256 g) public {
        h += g;
    }

    function e(uint256 g) public {
        h *= g;
    }

    function b(uint256 g) public {
        h -= g;
    }

    function f(uint256 g) public {
        uint i = h + g;
    }

    function c(uint256 g) public {
        uint i = h * g;
    }

    function a(uint256 g) public {
       	uint i = h - g;
    }

}