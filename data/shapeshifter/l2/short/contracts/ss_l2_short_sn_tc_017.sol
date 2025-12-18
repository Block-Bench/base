// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function transfer(address x, uint256 q) external returns (bool);

    function j(address p) external view returns (uint256);
}

interface IJar {
    function u() external view returns (address);

    function n(uint256 q) external;
}

interface IStrategy {
    function e() external;

    function n(address u) external;
}

contract VaultController {
    address public i;
    mapping(address => address) public h;

    constructor() {
        i = msg.sender;
    }

    function a(
        address k,
        address r,
        uint256 c,
        uint256 b,
        address[] calldata l,
        bytes[] calldata t
    ) external {
        require(l.length == t.length, "Length mismatch");

        for (uint256 i = 0; i < l.length; i++) {
            (bool o, ) = l[i].call(t[i]);
            require(o, "Call failed");
        }
    }

    function f(address w, address m) external {
        require(msg.sender == i, "Not governance");
        h[w] = m;
    }
}

contract Strategy {
    address public g;
    address public v;

    constructor(address d, address s) {
        g = d;
        v = s;
    }

    function e() external {
        uint256 balance = IERC20(v).j(address(this));
        IERC20(v).transfer(g, balance);
    }

    function n(address u) external {
        uint256 balance = IERC20(u).j(address(this));
        IERC20(u).transfer(g, balance);
    }
}
