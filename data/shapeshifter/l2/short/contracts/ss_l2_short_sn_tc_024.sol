// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function o(address w) external view returns (uint256);

    function transfer(address ac, uint256 x) external returns (bool);

    function i(
        address from,
        address ac,
        uint256 x
    ) external returns (bool);
}

interface ICurvePool {
    function b() external view returns (uint256);

    function h(
        uint256[3] calldata v,
        uint256 g
    ) external;
}

contract PriceOracle {
    ICurvePool public q;

    constructor(address m) {
        q = ICurvePool(m);
    }

    function r() external view returns (uint256) {
        return q.b();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 l;
        uint256 s;
    }

    mapping(address => Position) public n;

    address public e;
    address public k;
    address public z;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address d,
        address j,
        address u
    ) {
        e = d;
        k = j;
        z = u;
    }

    function t(uint256 x) external {
        IERC20(e).i(msg.sender, address(this), x);
        n[msg.sender].l += x;
    }

    function y(uint256 x) external {
        uint256 f = a(msg.sender);
        uint256 p = (f * COLLATERAL_FACTOR) / 100;

        require(
            n[msg.sender].s + x <= p,
            "Insufficient collateral"
        );

        n[msg.sender].s += x;
        IERC20(k).transfer(msg.sender, x);
    }

    function a(address ab) public view returns (uint256) {
        uint256 c = n[ab].l;
        uint256 aa = PriceOracle(z).r();

        return (c * aa) / 1e18;
    }
}
