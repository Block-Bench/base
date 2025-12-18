// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address ac, uint256 z) external returns (bool);

    function h(
        address from,
        address ac,
        uint256 z
    ) external returns (bool);

    function l(address w) external view returns (uint256);
}

interface IPancakeRouter {
    function a(
        uint o,
        uint m,
        address[] calldata ab,
        address ac,
        uint p
    ) external returns (uint[] memory t);
}

contract RewardMinter {
    IERC20 public v;
    IERC20 public j;

    mapping(address => uint256) public i;
    mapping(address => uint256) public e;

    uint256 public constant REWARD_RATE = 100;

    constructor(address n, address g) {
        v = IERC20(n);
        j = IERC20(g);
    }

    function s(uint256 z) external {
        v.h(msg.sender, address(this), z);
        i[msg.sender] += z;
    }

    function u(
        address aa,
        uint256 d,
        uint256 c,
        address ac,
        uint256
    ) external {
        require(aa == address(v), "Invalid token");

        uint256 x = c + d;
        v.h(msg.sender, address(this), x);

        uint256 b = f(
            v.l(address(this))
        );

        e[ac] += b;
    }

    function f(uint256 q) internal pure returns (uint256) {
        return q * REWARD_RATE;
    }

    function k() external {
        uint256 y = e[msg.sender];
        require(y > 0, "No rewards");

        e[msg.sender] = 0;
        j.transfer(msg.sender, y);
    }

    function r(uint256 z) external {
        require(i[msg.sender] >= z, "Insufficient balance");
        i[msg.sender] -= z;
        v.transfer(msg.sender, z);
    }
}
