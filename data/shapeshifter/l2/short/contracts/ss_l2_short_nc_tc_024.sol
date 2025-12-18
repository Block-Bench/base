pragma solidity ^0.8.0;

interface IERC20 {
    function o(address u) external view returns (uint256);

    function transfer(address ac, uint256 y) external returns (bool);

    function i(
        address from,
        address ac,
        uint256 y
    ) external returns (bool);
}

interface ICurvePool {
    function b() external view returns (uint256);

    function g(
        uint256[3] calldata t,
        uint256 h
    ) external;
}

contract PriceOracle {
    ICurvePool public p;

    constructor(address l) {
        p = ICurvePool(l);
    }

    function s() external view returns (uint256) {
        return p.b();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 m;
        uint256 r;
    }

    mapping(address => Position) public n;

    address public f;
    address public k;
    address public x;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address c,
        address j,
        address v
    ) {
        f = c;
        k = j;
        x = v;
    }

    function w(uint256 y) external {
        IERC20(f).i(msg.sender, address(this), y);
        n[msg.sender].m += y;
    }

    function z(uint256 y) external {
        uint256 e = a(msg.sender);
        uint256 q = (e * COLLATERAL_FACTOR) / 100;

        require(
            n[msg.sender].r + y <= q,
            "Insufficient collateral"
        );

        n[msg.sender].r += y;
        IERC20(k).transfer(msg.sender, y);
    }

    function a(address ab) public view returns (uint256) {
        uint256 d = n[ab].m;
        uint256 aa = PriceOracle(x).s();

        return (d * aa) / 1e18;
    }
}