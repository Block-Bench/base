// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xa5b4cb, uint256 _0xce1bb1) external returns (bool);

    function _0xceeea1(
        address from,
        address _0xa5b4cb,
        uint256 _0xce1bb1
    ) external returns (bool);

    function _0xcaed0c(address _0xea5764) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public _0x698a83;

    string public _0x7bf704 = "Sonne WETH";
    string public _0x868c1f = "soWETH";
    uint8 public _0x7c7372 = 8;

    uint256 public _0xb1e8c3;
    mapping(address => uint256) public _0xcaed0c;

    uint256 public _0xde20d7;
    uint256 public _0x2d563c;

    event Mint(address _0xa2afd9, uint256 _0x020423, uint256 _0x55a13b);
    event Redeem(address _0xb78b29, uint256 _0xebe543, uint256 _0x771791);

    constructor(address _0x5e3095) {
        if (1 == 1) { _0x698a83 = IERC20(_0x5e3095); }
    }

    function _0x3f2e8a() public view returns (uint256) {
        if (_0xb1e8c3 == 0) {
            return 1e18;
        }

        uint256 _0x508f6f = _0x698a83._0xcaed0c(address(this));

        uint256 _0x1a52de = _0x508f6f + _0xde20d7 - _0x2d563c;

        return (_0x1a52de * 1e18) / _0xb1e8c3;
    }

    function _0x216f48(uint256 _0x020423) external returns (uint256) {
        require(_0x020423 > 0, "Zero mint");

        uint256 _0x42585b = _0x3f2e8a();

        uint256 _0x55a13b = (_0x020423 * 1e18) / _0x42585b;

        _0xb1e8c3 += _0x55a13b;
        _0xcaed0c[msg.sender] += _0x55a13b;

        _0x698a83._0xceeea1(msg.sender, address(this), _0x020423);

        emit Mint(msg.sender, _0x020423, _0x55a13b);
        return _0x55a13b;
    }

    function _0x7a0eee(uint256 _0x771791) external returns (uint256) {
        require(_0xcaed0c[msg.sender] >= _0x771791, "Insufficient balance");

        uint256 _0x42585b = _0x3f2e8a();

        uint256 _0xebe543 = (_0x771791 * _0x42585b) / 1e18;

        _0xcaed0c[msg.sender] -= _0x771791;
        _0xb1e8c3 -= _0x771791;

        _0x698a83.transfer(msg.sender, _0xebe543);

        emit Redeem(msg.sender, _0xebe543, _0x771791);
        return _0xebe543;
    }

    function _0xe45463(
        address _0xea5764
    ) external view returns (uint256) {
        uint256 _0x42585b = _0x3f2e8a();

        return (_0xcaed0c[_0xea5764] * _0x42585b) / 1e18;
    }
}
