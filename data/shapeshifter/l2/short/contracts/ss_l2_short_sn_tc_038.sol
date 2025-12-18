// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 aa) external returns (bool);

    function h(
        address from,
        address ah,
        uint256 aa
    ) external returns (bool);

    function o(address z) external view returns (uint256);

    function x(address v, uint256 aa) external returns (bool);
}

interface IPriceOracle {
    function t(address af) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool q;
        uint256 c;
        mapping(address => uint256) b;
        mapping(address => uint256) f;
    }

    mapping(address => Market) public y;
    IPriceOracle public ad;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function g(
        address[] calldata w
    ) external returns (uint256[] memory) {
        uint256[] memory u = new uint256[](w.length);
        for (uint256 i = 0; i < w.length; i++) {
            y[w[i]].q = true;
            u[i] = 0;
        }
        return u;
    }

    function ag(address af, uint256 aa) external returns (uint256) {
        IERC20(af).h(msg.sender, address(this), aa);

        uint256 ae = ad.t(af);

        y[af].b[msg.sender] += aa;
        return 0;
    }

    function ab(
        address k,
        uint256 i
    ) external returns (uint256) {
        uint256 a = 0;

        uint256 m = ad.t(k);
        uint256 l = (i * m) / 1e18;

        uint256 e = (a * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(l <= e, "Insufficient collateral");

        y[k].f[msg.sender] += i;
        IERC20(k).transfer(msg.sender, i);

        return 0;
    }

    function p(
        address r,
        address n,
        uint256 j,
        address d
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public ac;

    function t(address af) external view override returns (uint256) {
        return ac[af];
    }

    function s(address af, uint256 ae) external {
        ac[af] = ae;
    }
}
