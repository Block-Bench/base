pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address z, uint256 t) external returns (bool);

    function g(
        address from,
        address z,
        uint256 t
    ) external returns (bool);

    function k(address r) external view returns (uint256);

    function q(address o, uint256 t) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public x = "Shezmu Collateral Token";
    string public v = "SCT";
    uint8 public n = 18;

    mapping(address => uint256) public k;
    mapping(address => mapping(address => uint256)) public j;
    uint256 public h;

    function y(address z, uint256 t) external {
        k[z] += t;
        h += t;
    }

    function transfer(
        address z,
        uint256 t
    ) external override returns (bool) {
        require(k[msg.sender] >= t, "Insufficient balance");
        k[msg.sender] -= t;
        k[z] += t;
        return true;
    }

    function g(
        address from,
        address z,
        uint256 t
    ) external override returns (bool) {
        require(k[from] >= t, "Insufficient balance");
        require(
            j[from][msg.sender] >= t,
            "Insufficient allowance"
        );
        k[from] -= t;
        k[z] += t;
        j[from][msg.sender] -= t;
        return true;
    }

    function q(
        address o,
        uint256 t
    ) external override returns (bool) {
        j[msg.sender][o] = t;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public e;
    IERC20 public p;

    mapping(address => uint256) public c;
    mapping(address => uint256) public i;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address d, address m) {
        e = IERC20(d);
        p = IERC20(m);
    }

    function f(uint256 t) external {
        e.g(msg.sender, address(this), t);
        c[msg.sender] += t;
    }

    function u(uint256 t) external {
        uint256 l = (c[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            i[msg.sender] + t <= l,
            "Insufficient collateral"
        );

        i[msg.sender] += t;

        p.transfer(msg.sender, t);
    }

    function w(uint256 t) external {
        require(i[msg.sender] >= t, "Excessive repayment");
        p.g(msg.sender, address(this), t);
        i[msg.sender] -= t;
    }

    function b(uint256 t) external {
        require(
            c[msg.sender] >= t,
            "Insufficient collateral"
        );
        uint256 a = c[msg.sender] - t;
        uint256 s = (a * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            i[msg.sender] <= s,
            "Would be undercollateralized"
        );

        c[msg.sender] -= t;
        e.transfer(msg.sender, t);
    }
}