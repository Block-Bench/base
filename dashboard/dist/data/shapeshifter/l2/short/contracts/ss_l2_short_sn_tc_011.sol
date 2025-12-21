// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function transfer(address s, uint256 n) external returns (bool);

    function i(address l) external view returns (uint256);
}

interface IERC1820Registry {
    function a(
        address l,
        bytes32 e,
        address f
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public j;
    mapping(address => uint256) public d;

    function m(address o, uint256 n) external returns (uint256) {
        IERC777 p = IERC777(o);

        require(p.transfer(address(this), n), "Transfer failed");

        j[msg.sender][o] += n;
        d[o] += n;

        return n;
    }

    function k(
        address o,
        uint256 b
    ) external returns (uint256) {
        uint256 g = j[msg.sender][o];
        require(g > 0, "No balance");

        uint256 c = b;
        if (b == type(uint256).r) {
            c = g;
        }
        require(c <= g, "Insufficient balance");

        IERC777(o).transfer(msg.sender, c);

        j[msg.sender][o] -= c;
        d[o] -= c;

        return c;
    }

    function h(
        address q,
        address o
    ) external view returns (uint256) {
        return j[q][o];
    }
}
