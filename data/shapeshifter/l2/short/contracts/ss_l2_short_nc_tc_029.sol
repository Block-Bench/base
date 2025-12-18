pragma solidity ^0.8.0;

interface IERC20 {
    function e(address i) external view returns (uint256);
    function transfer(address s, uint256 m) external returns (bool);
    function a(address from, address s, uint256 m) external returns (bool);
}

interface IPriceOracle {
    function h(address p) external view returns (uint256);
}

contract VaultStrategy {
    address public f;
    address public l;
    uint256 public c;

    mapping(address => uint256) public n;

    constructor(address q, address j) {
        f = q;
        l = j;
    }

    function k(uint256 m) external returns (uint256 d) {
        uint256 r = IERC20(f).e(address(this));

        if (c == 0) {
            d = m;
        } else {
            uint256 o = IPriceOracle(l).h(f);
            d = (m * c * 1e18) / (r * o);
        }

        n[msg.sender] += d;
        c += d;

        IERC20(f).a(msg.sender, address(this), m);
        return d;
    }

    function g(uint256 b) external {
        uint256 r = IERC20(f).e(address(this));

        uint256 o = IPriceOracle(l).h(f);
        uint256 m = (b * r * o) / (c * 1e18);

        n[msg.sender] -= b;
        c -= b;

        IERC20(f).transfer(msg.sender, m);
    }
}