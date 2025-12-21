pragma solidity ^0.8.0;

interface IERC20 {
    function p(address w) external view returns (uint256);

    function transfer(address ac, uint256 y) external returns (bool);

    function j(
        address from,
        address ac,
        uint256 y
    ) external returns (bool);
}

interface ICurvePool {
    function b() external view returns (uint256);

    function h(
        uint256[3] calldata t,
        uint256 g
    ) external;
}

contract PriceOracle {
    ICurvePool public o;

    constructor(address l) {
        o = ICurvePool(l);
    }

    function r() external view returns (uint256) {
        return o.b();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 m;
        uint256 s;
    }

    mapping(address => Position) public n;

    address public e;
    address public k;
    address public z;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address d,
        address i,
        address v
    ) {
        e = d;
        k = i;
        z = v;
    }

    function u(uint256 y) external {
        IERC20(e).j(msg.sender, address(this), y);
        n[msg.sender].m += y;
    }

    function x(uint256 y) external {
        uint256 f = a(msg.sender);
        uint256 q = (f * COLLATERAL_FACTOR) / 100;

        require(
            n[msg.sender].s + y <= q,
            "Insufficient collateral"
        );

        n[msg.sender].s += y;
        IERC20(k).transfer(msg.sender, y);
    }

    function a(address ab) public view returns (uint256) {
        uint256 c = n[ab].m;
        uint256 aa = PriceOracle(z).r();

        return (c * aa) / 1e18;
    }
}