pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address ac, uint256 y) external returns (bool);

    function g(
        address from,
        address ac,
        uint256 y
    ) external returns (bool);

    function m(address u) external view returns (uint256);
}

interface IPancakeRouter {
    function a(
        uint r,
        uint l,
        address[] calldata ab,
        address ac,
        uint q
    ) external returns (uint[] memory s);
}

contract RewardMinter {
    IERC20 public w;
    IERC20 public i;

    mapping(address => uint256) public j;
    mapping(address => uint256) public e;

    uint256 public constant REWARD_RATE = 100;

    constructor(address p, address h) {
        w = IERC20(p);
        i = IERC20(h);
    }

    function v(uint256 y) external {
        w.g(msg.sender, address(this), y);
        j[msg.sender] += y;
    }

    function t(
        address aa,
        uint256 d,
        uint256 c,
        address ac,
        uint256
    ) external {
        require(aa == address(w), "Invalid token");

        uint256 x = c + d;
        w.g(msg.sender, address(this), x);

        uint256 b = f(
            w.m(address(this))
        );

        e[ac] += b;
    }

    function f(uint256 o) internal pure returns (uint256) {
        return o * REWARD_RATE;
    }

    function k() external {
        uint256 z = e[msg.sender];
        require(z > 0, "No rewards");

        e[msg.sender] = 0;
        i.transfer(msg.sender, z);
    }

    function n(uint256 y) external {
        require(j[msg.sender] >= y, "Insufficient balance");
        j[msg.sender] -= y;
        w.transfer(msg.sender, y);
    }
}