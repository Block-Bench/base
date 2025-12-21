// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function g(
        uint256[3] memory u,
        uint256 d
    ) external;

    function a(
        uint256[3] memory u,
        uint256 c
    ) external;

    function b() external view returns (uint256);
}

interface IERC20 {
    function transfer(address ad, uint256 w) external returns (bool);

    function j(
        address from,
        address ad,
        uint256 w
    ) external returns (bool);

    function q(address v) external view returns (uint256);

    function t(address r, uint256 w) external returns (bool);
}

contract YieldVault {
    IERC20 public ac;
    IERC20 public z;
    ICurve3Pool public p;

    mapping(address => uint256) public x;
    uint256 public n;
    uint256 public f;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address ab, address y, address m) {
        ac = IERC20(ab);
        z = IERC20(y);
        p = ICurve3Pool(m);
    }

    function s(uint256 w) external {
        ac.j(msg.sender, address(this), w);

        uint256 l;
        if (n == 0) {
            l = w;
        } else {
            l = (w * n) / f;
        }

        x[msg.sender] += l;
        n += l;
        f += w;
    }

    function aa() external {
        uint256 h = ac.q(address(this));
        require(
            h >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 i = p.b();

        ac.t(address(p), h);
        uint256[3] memory u = [h, 0, 0];
        p.g(u, 0);
    }

    function k() external {
        uint256 o = x[msg.sender];
        require(o > 0, "No shares");

        uint256 e = (o * f) / n;

        x[msg.sender] = 0;
        n -= o;
        f -= e;

        ac.transfer(msg.sender, e);
    }

    function balance() public view returns (uint256) {
        return
            ac.q(address(this)) +
            (z.q(address(this)) * p.b()) /
            1e18;
    }
}
