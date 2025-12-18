// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address m, uint256 j) external returns (bool);
    function c(address from, address m, uint256 j) external returns (bool);
}

interface ICompoundToken {
    function k(uint256 j) external;
    function f(uint256 j) external;
    function i(uint256 h) external;
    function l(uint256 j) external;
}

contract LendingMarket {
    mapping(address => uint256) public a;
    mapping(address => uint256) public b;

    address public g;
    uint256 public d;

    constructor(address e) {
        g = e;
    }

    function k(uint256 j) external {
        a[msg.sender] += j;
        d += j;

        IERC20(g).transfer(msg.sender, j);
    }

    function f(uint256 j) external {
        IERC20(g).c(msg.sender, address(this), j);

        a[msg.sender] -= j;
        d -= j;
    }
}
