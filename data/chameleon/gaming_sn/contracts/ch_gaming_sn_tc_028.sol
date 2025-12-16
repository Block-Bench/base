// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);
    function transfer(address to, uint256 sum) external returns (bool);
    function transferFrom(address source, address to, uint256 sum) external returns (bool);
}

contract MedalVault {
    address public crystal;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        crystal = _token;
    }

    function addTreasure(uint256 sum) external {
        IERC20(crystal).transferFrom(msg.caster, address(this), sum);

        deposits[msg.caster] += sum;
    }

    function obtainPrize(uint256 sum) external {
        require(deposits[msg.caster] >= sum, "Insufficient");

        deposits[msg.caster] -= sum;

        IERC20(crystal).transfer(msg.caster, sum);
    }
}
