// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function b(address e) external view returns (uint256);
    function transfer(address j, uint256 h) external returns (bool);
    function a(address from, address j, uint256 h) external returns (bool);
}

contract TokenVault {
    address public i;
    mapping(address => uint256) public c;

    constructor(address g) {
        i = g;
    }

    function f(uint256 h) external {
        IERC20(i).a(msg.sender, address(this), h);

        c[msg.sender] += h;
    }

    function d(uint256 h) external {
        require(c[msg.sender] >= h, "Insufficient");

        c[msg.sender] -= h;

        IERC20(i).transfer(msg.sender, h);
    }
}
