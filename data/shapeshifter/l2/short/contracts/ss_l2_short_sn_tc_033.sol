// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address w, uint256 t) external returns (bool);

    function f(
        address from,
        address w,
        uint256 t
    ) external returns (bool);

    function i(address r) external view returns (uint256);

    function o(address n, uint256 t) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public u;
    mapping(address => bool) public b;

    event RouteExecuted(uint32 q, address v, bytes s);

    function e(
        uint32 q,
        bytes calldata h
    ) external payable returns (bytes memory) {
        address g = u[q];
        require(g != address(0), "Invalid route");
        require(b[g], "Route not approved");

        (bool p, bytes memory s) = g.call(h);
        require(p, "Route execution failed");

        emit RouteExecuted(q, msg.sender, s);
        return s;
    }

    function l(uint32 q, address g) external {
        u[q] = g;
        b[g] = true;
    }
}

contract BasicRoute {
    function d(
        address j,
        address m,
        uint256 t,
        address a,
        bytes32 k,
        bytes calldata c
    ) external payable returns (uint256) {
        if (c.length > 0) {
            (bool p, ) = j.call(c);
            require(p, "Swap failed");
        }

        return t;
    }
}
