// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Protocol
 * @notice Manages collateral deposits and borrowing
 */

interface IComptroller {
    function g(
        address[] memory q
    ) external returns (uint256[] memory);

    function j(address v) external returns (uint256);

    function b(
        address s
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public i;

    mapping(address => uint256) public m;
    mapping(address => uint256) public p;
    mapping(address => bool) public n;

    uint256 public f;
    uint256 public e;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address h) {
        i = IComptroller(h);
    }

    function a() external payable {
        m[msg.sender] += msg.value;
        f += msg.value;
        n[msg.sender] = true;
    }

    function k(
        address s,
        uint256 c
    ) public view returns (bool) {
        uint256 l = p[s] + c;
        if (l == 0) return true;

        if (!n[s]) return false;

        uint256 d = m[s];
        return d >= (l * COLLATERAL_FACTOR) / 100;
    }

    function u(uint256 t) external {
        require(t > 0, "Invalid amount");
        require(address(this).balance >= t, "Insufficient funds");

        require(k(msg.sender, t), "Insufficient collateral");

        p[msg.sender] += t;
        e += t;

        (bool r, ) = payable(msg.sender).call{value: t}("");
        require(r, "Transfer failed");

        require(k(msg.sender, 0), "Health check failed");
    }

    function j() external {
        require(p[msg.sender] == 0, "Outstanding debt");
        n[msg.sender] = false;
    }

    function o(uint256 t) external {
        require(m[msg.sender] >= t, "Insufficient deposits");
        require(!n[msg.sender], "Exit market first");

        m[msg.sender] -= t;
        f -= t;

        payable(msg.sender).transfer(t);
    }

    receive() external payable {}
}
