pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address w, uint256 t) external returns (bool);

    function e(
        address from,
        address w,
        uint256 t
    ) external returns (bool);

    function j(address r) external view returns (uint256);

    function q(address m, uint256 t) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public s;
    mapping(address => bool) public b;

    event RouteExecuted(uint32 o, address v, bytes u);

    function f(
        uint32 o,
        bytes calldata h
    ) external payable returns (bytes memory) {
        address g = s[o];
        require(g != address(0), "Invalid route");
        require(b[g], "Route not approved");

        (bool n, bytes memory u) = g.call(h);
        require(n, "Route execution failed");

        emit RouteExecuted(o, msg.sender, u);
        return u;
    }

    function l(uint32 o, address g) external {
        s[o] = g;
        b[g] = true;
    }
}

contract BasicRoute {
    function c(
        address i,
        address p,
        uint256 t,
        address a,
        bytes32 k,
        bytes calldata d
    ) external payable returns (uint256) {
        if (d.length > 0) {
            (bool n, ) = i.call(d);
            require(n, "Swap failed");
        }

        return t;
    }
}