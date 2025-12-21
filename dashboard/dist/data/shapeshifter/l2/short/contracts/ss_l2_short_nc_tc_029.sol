pragma solidity ^0.8.0;

interface IERC20 {
    function f(address k) external view returns (uint256);
    function transfer(address s, uint256 l) external returns (bool);
    function a(address from, address s, uint256 l) external returns (bool);
}

interface IPriceOracle {
    function g(address o) external view returns (uint256);
}

contract VaultStrategy {
    address public e;
    address public n;
    uint256 public d;

    mapping(address => uint256) public m;

    constructor(address q, address j) {
        e = q;
        n = j;
    }

    function i(uint256 l) external returns (uint256 c) {
        uint256 r = IERC20(e).f(address(this));

        if (d == 0) {
            c = l;
        } else {
            uint256 p = IPriceOracle(n).g(e);
            c = (l * d * 1e18) / (r * p);
        }

        m[msg.sender] += c;
        d += c;

        IERC20(e).a(msg.sender, address(this), l);
        return c;
    }

    function h(uint256 b) external {
        uint256 r = IERC20(e).f(address(this));

        uint256 p = IPriceOracle(n).g(e);
        uint256 l = (b * r * p) / (d * 1e18);

        m[msg.sender] -= b;
        d -= b;

        IERC20(e).transfer(msg.sender, l);
    }
}