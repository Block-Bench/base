// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address _0x63358d, uint256 _0x2a22b0) external returns (bool);

    function _0x04c62c(
        address from,
        address _0x63358d,
        uint256 _0x2a22b0
    ) external returns (bool);

    function _0xd1b0ca(address _0xe8b8a5) external view returns (uint256);
}

interface IPancakeRouter {
    function _0x050070(
        uint _0xb73dcd,
        uint _0xd924cb,
        address[] calldata _0x47705b,
        address _0x63358d,
        uint _0x4293c7
    ) external returns (uint[] memory _0xda21a6);
}

contract RewardMinter {
    IERC20 public _0x59e6f2;
    IERC20 public _0x2aef9b;

    mapping(address => uint256) public _0xff74c4;
    mapping(address => uint256) public _0x1f4192;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0x4b0e7a, address _0xc09514) {
        _0x59e6f2 = IERC20(_0x4b0e7a);
        _0x2aef9b = IERC20(_0xc09514);
    }

    function _0xff302f(uint256 _0x2a22b0) external {
        _0x59e6f2._0x04c62c(msg.sender, address(this), _0x2a22b0);
        _0xff74c4[msg.sender] += _0x2a22b0;
    }

    function _0x785886(
        address _0x15d265,
        uint256 _0xc21c21,
        uint256 _0x4a3621,
        address _0x63358d,
        uint256
    ) external {
        require(_0x15d265 == address(_0x59e6f2), "Invalid token");

        uint256 _0x8c468b = _0x4a3621 + _0xc21c21;
        _0x59e6f2._0x04c62c(msg.sender, address(this), _0x8c468b);

        uint256 _0xd2ada0 = _0x0f84bb(
            _0x59e6f2._0xd1b0ca(address(this))
        );

        _0x1f4192[_0x63358d] += _0xd2ada0;
    }

    function _0x0f84bb(uint256 _0xecfbf6) internal pure returns (uint256) {
        return _0xecfbf6 * REWARD_RATE;
    }

    function _0xa21c62() external {
        uint256 _0x1b555c = _0x1f4192[msg.sender];
        require(_0x1b555c > 0, "No rewards");

        _0x1f4192[msg.sender] = 0;
        _0x2aef9b.transfer(msg.sender, _0x1b555c);
    }

    function _0xf02052(uint256 _0x2a22b0) external {
        require(_0xff74c4[msg.sender] >= _0x2a22b0, "Insufficient balance");
        _0xff74c4[msg.sender] -= _0x2a22b0;
        _0x59e6f2.transfer(msg.sender, _0x2a22b0);
    }
}
