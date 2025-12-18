// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address _0xb643f4, uint256 _0x1154b1) external returns (bool);

    function _0xf61fdd(
        address from,
        address _0xb643f4,
        uint256 _0x1154b1
    ) external returns (bool);

    function _0xb5f8a4(address _0x51888b) external view returns (uint256);
}

interface IPancakeRouter {
    function _0x23157b(
        uint _0xb87229,
        uint _0xc9d0c1,
        address[] calldata _0x747726,
        address _0xb643f4,
        uint _0x8c59a4
    ) external returns (uint[] memory _0x8e2e82);
}

contract RewardMinter {
    IERC20 public _0xc46368;
    IERC20 public _0xab3cdc;

    mapping(address => uint256) public _0xc07f15;
    mapping(address => uint256) public _0x18b7bb;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0xfedbb1, address _0xd14fff) {
        _0xc46368 = IERC20(_0xfedbb1);
        _0xab3cdc = IERC20(_0xd14fff);
    }

    function _0xcd4de2(uint256 _0x1154b1) external {
        _0xc46368._0xf61fdd(msg.sender, address(this), _0x1154b1);
        _0xc07f15[msg.sender] += _0x1154b1;
    }

    function _0x2aae62(
        address _0x1239ab,
        uint256 _0x759607,
        uint256 _0x6cf5bd,
        address _0xb643f4,
        uint256
    ) external {
        require(_0x1239ab == address(_0xc46368), "Invalid token");

        uint256 _0xf6133e = _0x6cf5bd + _0x759607;
        _0xc46368._0xf61fdd(msg.sender, address(this), _0xf6133e);

        uint256 _0x406114 = _0xe7c29b(
            _0xc46368._0xb5f8a4(address(this))
        );

        _0x18b7bb[_0xb643f4] += _0x406114;
    }

    function _0xe7c29b(uint256 _0x42a625) internal pure returns (uint256) {
        return _0x42a625 * REWARD_RATE;
    }

    function _0x971b6c() external {
        uint256 _0x61504c = _0x18b7bb[msg.sender];
        require(_0x61504c > 0, "No rewards");

        _0x18b7bb[msg.sender] = 0;
        _0xab3cdc.transfer(msg.sender, _0x61504c);
    }

    function _0xb1adeb(uint256 _0x1154b1) external {
        require(_0xc07f15[msg.sender] >= _0x1154b1, "Insufficient balance");
        _0xc07f15[msg.sender] -= _0x1154b1;
        _0xc46368.transfer(msg.sender, _0x1154b1);
    }
}
