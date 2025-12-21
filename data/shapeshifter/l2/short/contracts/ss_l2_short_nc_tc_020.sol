pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function i()
        external
        view
        returns (uint112 s, uint112 p, uint32 a);

    function g() external view returns (uint256);
}

interface IERC20 {
    function n(address z) external view returns (uint256);

    function transfer(address af, uint256 ab) external returns (bool);

    function f(
        address from,
        address af,
        uint256 ab
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 e;
        uint256 u;
    }

    mapping(address => Position) public m;

    address public y;
    address public l;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address t, address h) {
        y = t;
        l = h;
    }

    function v(uint256 ab) external {
        IERC20(y).f(msg.sender, address(this), ab);
        m[msg.sender].e += ab;
    }

    function aa(uint256 ab) external {
        uint256 c = b(
            m[msg.sender].e
        );
        uint256 o = (c * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].u + ab <= o,
            "Insufficient collateral"
        );

        m[msg.sender].u += ab;
        IERC20(l).transfer(msg.sender, ab);
    }

    function b(uint256 q) public view returns (uint256) {
        if (q == 0) return 0;

        IUniswapV2Pair ae = IUniswapV2Pair(y);

        (uint112 s, uint112 p, ) = ae.i();
        uint256 g = ae.g();

        uint256 w = (uint256(s) * q) / g;
        uint256 x = (uint256(p) * q) / g;

        uint256 ac = w;
        uint256 k = w + x;

        return k;
    }

    function ad(uint256 ab) external {
        require(m[msg.sender].u >= ab, "Repay exceeds debt");

        IERC20(l).f(msg.sender, address(this), ab);
        m[msg.sender].u -= ab;
    }

    function r(uint256 ab) external {
        require(
            m[msg.sender].e >= ab,
            "Insufficient balance"
        );

        uint256 j = m[msg.sender].e - ab;
        uint256 d = b(j);
        uint256 o = (d * 100) / COLLATERAL_RATIO;

        require(
            m[msg.sender].u <= o,
            "Withdrawal would liquidate position"
        );

        m[msg.sender].e -= ab;
        IERC20(y).transfer(msg.sender, ab);
    }
}