pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address ac, uint256 x) external returns (bool);

    function g(
        address from,
        address ac,
        uint256 x
    ) external returns (bool);

    function k(address w) external view returns (uint256);
}

interface IPancakeRouter {
    function a(
        uint p,
        uint l,
        address[] calldata ab,
        address ac,
        uint n
    ) external returns (uint[] memory s);
}

contract RewardMinter {
    IERC20 public v;
    IERC20 public i;

    mapping(address => uint256) public j;
    mapping(address => uint256) public e;

    uint256 public constant REWARD_RATE = 100;

    constructor(address r, address h) {
        v = IERC20(r);
        i = IERC20(h);
    }

    function t(uint256 x) external {
        v.g(msg.sender, address(this), x);
        j[msg.sender] += x;
    }

    function u(
        address aa,
        uint256 d,
        uint256 c,
        address ac,
        uint256
    ) external {
        require(aa == address(v), "Invalid token");

        uint256 z = c + d;
        v.g(msg.sender, address(this), z);

        uint256 b = f(
            v.k(address(this))
        );

        e[ac] += b;
    }

    function f(uint256 o) internal pure returns (uint256) {
        return o * REWARD_RATE;
    }

    function m() external {
        uint256 y = e[msg.sender];
        require(y > 0, "No rewards");

        e[msg.sender] = 0;
        i.transfer(msg.sender, y);
    }

    function q(uint256 x) external {
        require(j[msg.sender] >= x, "Insufficient balance");
        j[msg.sender] -= x;
        v.transfer(msg.sender, x);
    }
}