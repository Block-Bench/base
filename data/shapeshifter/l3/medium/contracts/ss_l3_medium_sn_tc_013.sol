// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Reward Minter Contract
 * @notice Manages LP token deposits and reward minting
 */

interface IERC20 {
    function transfer(address _0xe992d2, uint256 _0x37bfed) external returns (bool);

    function _0x7a2e39(
        address from,
        address _0xe992d2,
        uint256 _0x37bfed
    ) external returns (bool);

    function _0x0410db(address _0x09ef97) external view returns (uint256);
}

interface IPancakeRouter {
    function _0x703903(
        uint _0xb8bd8b,
        uint _0x12946a,
        address[] calldata _0x847c37,
        address _0xe992d2,
        uint _0x914359
    ) external returns (uint[] memory _0xcda83d);
}

contract RewardMinter {
    IERC20 public _0xad34e7;
    IERC20 public _0xfdb05a;

    mapping(address => uint256) public _0x832a8e;
    mapping(address => uint256) public _0x9e8b1e;

    uint256 public constant REWARD_RATE = 100;

    constructor(address _0xb6eee5, address _0xf289d9) {
        _0xad34e7 = IERC20(_0xb6eee5);
        _0xfdb05a = IERC20(_0xf289d9);
    }

    function _0x332f08(uint256 _0x37bfed) external {
        _0xad34e7._0x7a2e39(msg.sender, address(this), _0x37bfed);
        _0x832a8e[msg.sender] += _0x37bfed;
    }

    function _0xf3bd18(
        address _0xb1a673,
        uint256 _0x9ca42d,
        uint256 _0x76c686,
        address _0xe992d2,
        uint256
    ) external {
        require(_0xb1a673 == address(_0xad34e7), "Invalid token");

        uint256 _0xcd47a5 = _0x76c686 + _0x9ca42d;
        _0xad34e7._0x7a2e39(msg.sender, address(this), _0xcd47a5);

        uint256 _0xd9eb2a = _0x3bd70f(
            _0xad34e7._0x0410db(address(this))
        );

        _0x9e8b1e[_0xe992d2] += _0xd9eb2a;
    }

    function _0x3bd70f(uint256 _0xd6e676) internal pure returns (uint256) {
        return _0xd6e676 * REWARD_RATE;
    }

    function _0xdda38f() external {
        uint256 _0xeb3970 = _0x9e8b1e[msg.sender];
        require(_0xeb3970 > 0, "No rewards");

        _0x9e8b1e[msg.sender] = 0;
        _0xfdb05a.transfer(msg.sender, _0xeb3970);
    }

    function _0x6a4b91(uint256 _0x37bfed) external {
        require(_0x832a8e[msg.sender] >= _0x37bfed, "Insufficient balance");
        _0x832a8e[msg.sender] -= _0x37bfed;
        _0xad34e7.transfer(msg.sender, _0x37bfed);
    }
}
