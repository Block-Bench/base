pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ah, uint256 ab) external returns (bool);

    function g(
        address from,
        address ah,
        uint256 ab
    ) external returns (bool);

    function o(address x) external view returns (uint256);

    function v(address u, uint256 ab) external returns (bool);
}

interface IPriceOracle {
    function r(address af) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool t;
        uint256 c;
        mapping(address => uint256) b;
        mapping(address => uint256) f;
    }

    mapping(address => Market) public y;
    IPriceOracle public aa;

    uint256 public constant COLLATERAL_FACTOR = 75;
    uint256 public constant BASIS_POINTS = 100;

    function i(
        address[] calldata w
    ) external returns (uint256[] memory) {
        uint256[] memory z = new uint256[](w.length);
        for (uint256 i = 0; i < w.length; i++) {
            y[w[i]].t = true;
            z[i] = 0;
        }
        return z;
    }

    function ag(address af, uint256 ab) external returns (uint256) {
        IERC20(af).g(msg.sender, address(this), ab);

        uint256 ae = aa.r(af);

        y[af].b[msg.sender] += ab;
        return 0;
    }

    function ac(
        address j,
        uint256 h
    ) external returns (uint256) {
        uint256 a = 0;

        uint256 l = aa.r(j);
        uint256 m = (h * l) / 1e18;

        uint256 e = (a * COLLATERAL_FACTOR) /
            BASIS_POINTS;

        require(m <= e, "Insufficient collateral");

        y[j].f[msg.sender] += h;
        IERC20(j).transfer(msg.sender, h);

        return 0;
    }

    function p(
        address s,
        address n,
        uint256 k,
        address d
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public ad;

    function r(address af) external view override returns (uint256) {
        return ad[af];
    }

    function q(address af, uint256 ae) external {
        ad[af] = ae;
    }
}