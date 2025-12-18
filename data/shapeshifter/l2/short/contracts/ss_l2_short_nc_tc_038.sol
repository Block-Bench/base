pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 ab) external returns (bool);

    function i(
        address from,
        address ah,
        uint256 ab
    ) external returns (bool);

    function p(address z) external view returns (uint256);

    function y(address w, uint256 ab) external returns (bool);
}

interface IPriceOracle {
    function q(address ae) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool s;
        uint256 c;
        mapping(address => uint256) b;
        mapping(address => uint256) f;
    }

    mapping(address => Market) public u;
    IPriceOracle public ad;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function h(
        address[] calldata v
    ) external returns (uint256[] memory) {
        uint256[] memory x = new uint256[](v.length);
        for (uint256 i = 0; i < v.length; i++) {
            u[v[i]].s = true;
            x[i] = 0;
        }
        return x;
    }

    function ag(address ae, uint256 ab) external returns (uint256) {
        IERC20(ae).i(msg.sender, address(this), ab);

        uint256 af = ad.q(ae);

        u[ae].b[msg.sender] += ab;
        return 0;
    }

    function aa(
        address k,
        uint256 g
    ) external returns (uint256) {
        uint256 a = 0;

        uint256 l = ad.q(k);
        uint256 m = (g * l) / 1e18;

        uint256 e = (a * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(m <= e, "Insufficient collateral");

        u[k].f[msg.sender] += g;
        IERC20(k).transfer(msg.sender, g);

        return 0;
    }

    function o(
        address r,
        address n,
        uint256 j,
        address d
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public ac;

    function q(address ae) external view override returns (uint256) {
        return ac[ae];
    }

    function t(address ae, uint256 af) external {
        ac[ae] = af;
    }
}