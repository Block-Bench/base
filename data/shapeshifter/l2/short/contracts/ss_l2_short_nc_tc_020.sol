pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function j()
        external
        view
        returns (uint112 u, uint112 p, uint32 a);

    function i() external view returns (uint256);
}

interface IERC20 {
    function n(address w) external view returns (uint256);

    function transfer(address af, uint256 aa) external returns (bool);

    function f(
        address from,
        address af,
        uint256 aa
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 e;
        uint256 q;
    }

    mapping(address => Position) public m;

    address public z;
    address public k;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address t, address g) {
        z = t;
        k = g;
    }

    function y(uint256 aa) external {
        IERC20(z).f(msg.sender, address(this), aa);
        m[msg.sender].e += aa;
    }

    function ac(uint256 aa) external {
        uint256 b = c(
            m[msg.sender].e
        );
        uint256 o = (b * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].q + aa <= o,
            "Insufficient collateral"
        );

        m[msg.sender].q += aa;
        IERC20(k).transfer(msg.sender, aa);
    }

    function c(uint256 s) public view returns (uint256) {
        if (s == 0) return 0;

        IUniswapV2Pair ae = IUniswapV2Pair(z);

        (uint112 u, uint112 p, ) = ae.j();
        uint256 i = ae.i();

        uint256 x = (uint256(u) * s) / i;
        uint256 v = (uint256(p) * s) / i;

        uint256 ab = x;
        uint256 l = x + v;

        return l;
    }

    function ad(uint256 aa) external {
        require(m[msg.sender].q >= aa, "Repay exceeds debt");

        IERC20(k).f(msg.sender, address(this), aa);
        m[msg.sender].q -= aa;
    }

    function r(uint256 aa) external {
        require(
            m[msg.sender].e >= aa,
            "Insufficient balance"
        );

        uint256 h = m[msg.sender].e - aa;
        uint256 d = c(h);
        uint256 o = (d * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].q <= o,
            "Withdrawal would liquidate position"
        );

        m[msg.sender].e -= aa;
        IERC20(z).transfer(msg.sender, aa);
    }
}