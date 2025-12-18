pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address z, uint256 v) external returns (bool);

    function g(
        address from,
        address z,
        uint256 v
    ) external returns (bool);

    function j(address s) external view returns (uint256);

    function r(address q, uint256 v) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public x = "Shezmu Collateral Token";
    string public t = "SCT";
    uint8 public n = 18;

    mapping(address => uint256) public j;
    mapping(address => mapping(address => uint256)) public l;
    uint256 public h;

    function y(address z, uint256 v) external {
        j[z] += v;
        h += v;
    }

    function transfer(
        address z,
        uint256 v
    ) external override returns (bool) {
        require(j[msg.sender] >= v, "Insufficient balance");
        j[msg.sender] -= v;
        j[z] += v;
        return true;
    }

    function g(
        address from,
        address z,
        uint256 v
    ) external override returns (bool) {
        require(j[from] >= v, "Insufficient balance");
        require(
            l[from][msg.sender] >= v,
            "Insufficient allowance"
        );
        j[from] -= v;
        j[z] += v;
        l[from][msg.sender] -= v;
        return true;
    }

    function r(
        address q,
        uint256 v
    ) external override returns (bool) {
        l[msg.sender][q] = v;
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

    function f(uint256 v) external {
        e.g(msg.sender, address(this), v);
        c[msg.sender] += v;
    }

    function u(uint256 v) external {
        uint256 k = (c[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            i[msg.sender] + v <= k,
            "Insufficient collateral"
        );

        i[msg.sender] += v;

        p.transfer(msg.sender, v);
    }

    function w(uint256 v) external {
        require(i[msg.sender] >= v, "Excessive repayment");
        p.g(msg.sender, address(this), v);
        i[msg.sender] -= v;
    }

    function b(uint256 v) external {
        require(
            c[msg.sender] >= v,
            "Insufficient collateral"
        );
        uint256 a = c[msg.sender] - v;
        uint256 o = (a * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            i[msg.sender] <= o,
            "Would be undercollateralized"
        );

        c[msg.sender] -= v;
        e.transfer(msg.sender, v);
    }
}