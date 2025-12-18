// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address z, uint256 u) external returns (bool);

    function e(
        address from,
        address z,
        uint256 u
    ) external returns (bool);

    function o(address r) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public l;

    string public x = "Sonne WETH";
    string public v = "soWETH";
    uint8 public p = 8;

    uint256 public j;
    mapping(address => uint256) public o;

    uint256 public g;
    uint256 public d;

    event Mint(address s, uint256 n, uint256 m);
    event Redeem(address q, uint256 h, uint256 f);

    constructor(address k) {
        l = IERC20(k);
    }

    function i() public view returns (uint256) {
        if (j == 0) {
            return 1e18;
        }

        uint256 y = l.o(address(this));

        uint256 c = y + g - d;

        return (c * 1e18) / j;
    }

    function w(uint256 n) external returns (uint256) {
        require(n > 0, "Zero mint");

        uint256 a = i();

        uint256 m = (n * 1e18) / a;

        j += m;
        o[msg.sender] += m;

        l.e(msg.sender, address(this), n);

        emit Mint(msg.sender, n, m);
        return m;
    }

    function t(uint256 f) external returns (uint256) {
        require(o[msg.sender] >= f, "Insufficient balance");

        uint256 a = i();

        uint256 h = (f * a) / 1e18;

        o[msg.sender] -= f;
        j -= f;

        l.transfer(msg.sender, h);

        emit Redeem(msg.sender, h, f);
        return h;
    }

    function b(
        address r
    ) external view returns (uint256) {
        uint256 a = i();

        return (o[r] * a) / 1e18;
    }
}
