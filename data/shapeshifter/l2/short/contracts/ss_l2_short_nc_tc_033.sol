pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address w, uint256 s) external returns (bool);

    function f(
        address from,
        address w,
        uint256 s
    ) external returns (bool);

    function j(address r) external view returns (uint256);

    function q(address o, uint256 s) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public t;
    mapping(address => bool) public b;

    event RouteExecuted(uint32 p, address v, bytes u);

    function e(
        uint32 p,
        bytes calldata h
    ) external payable returns (bytes memory) {
        address g = t[p];
        require(g != address(0), "Invalid route");
        require(b[g], "Route not approved");

        (bool n, bytes memory u) = g.call(h);
        require(n, "Route execution failed");

        emit RouteExecuted(p, msg.sender, u);
        return u;
    }

    function l(uint32 p, address g) external {
        t[p] = g;
        b[g] = true;
    }
}

contract BasicRoute {
    function d(
        address i,
        address m,
        uint256 s,
        address a,
        bytes32 k,
        bytes calldata c
    ) external payable returns (uint256) {
        if (c.length > 0) {
            (bool n, ) = i.call(c);
            require(n, "Swap failed");
        }

        return s;
    }
}