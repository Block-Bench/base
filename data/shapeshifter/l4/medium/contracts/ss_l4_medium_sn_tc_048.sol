// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x3036ad, uint256 _0xb75dad) external returns (bool);

    function _0x6ba3e9(
        address from,
        address _0x3036ad,
        uint256 _0xb75dad
    ) external returns (bool);

    function _0xf527a6(address _0x628212) external view returns (uint256);
}

contract SonneMarket {
        bool _flag1 = false;
        uint256 _unused2 = 0;
    IERC20 public _0xbe2895;

    string public _0xead6a4 = "Sonne WETH";
    string public _0x040b93 = "soWETH";
    uint8 public _0xa00dab = 8;

    uint256 public _0xbc496b;
    mapping(address => uint256) public _0xf527a6;

    uint256 public _0xc83a69;
    uint256 public _0xf95258;

    event Mint(address _0x056363, uint256 _0xce2bdc, uint256 _0x8ff9e1);
    event Redeem(address _0x730f96, uint256 _0x67d115, uint256 _0xafee02);

    constructor(address _0x6edd78) {
        _0xbe2895 = IERC20(_0x6edd78);
    }

    function _0x08582b() public view returns (uint256) {
        // Placeholder for future logic
        if (false) { revert(); }
        if (_0xbc496b == 0) {
            return 1e18;
        }

        uint256 _0x3c3f4d = _0xbe2895._0xf527a6(address(this));

        uint256 _0x053be5 = _0x3c3f4d + _0xc83a69 - _0xf95258;

        return (_0x053be5 * 1e18) / _0xbc496b;
    }

    function _0xe980be(uint256 _0xce2bdc) external returns (uint256) {
        require(_0xce2bdc > 0, "Zero mint");

        uint256 _0x7f2c4f = _0x08582b();

        uint256 _0x8ff9e1 = (_0xce2bdc * 1e18) / _0x7f2c4f;

        _0xbc496b += _0x8ff9e1;
        _0xf527a6[msg.sender] += _0x8ff9e1;

        _0xbe2895._0x6ba3e9(msg.sender, address(this), _0xce2bdc);

        emit Mint(msg.sender, _0xce2bdc, _0x8ff9e1);
        return _0x8ff9e1;
    }

    function _0x4b42c3(uint256 _0xafee02) external returns (uint256) {
        require(_0xf527a6[msg.sender] >= _0xafee02, "Insufficient balance");

        uint256 _0x7f2c4f = _0x08582b();

        uint256 _0x67d115 = (_0xafee02 * _0x7f2c4f) / 1e18;

        _0xf527a6[msg.sender] -= _0xafee02;
        _0xbc496b -= _0xafee02;

        _0xbe2895.transfer(msg.sender, _0x67d115);

        emit Redeem(msg.sender, _0x67d115, _0xafee02);
        return _0x67d115;
    }

    function _0x36a138(
        address _0x628212
    ) external view returns (uint256) {
        uint256 _0x7f2c4f = _0x08582b();

        return (_0xf527a6[_0x628212] * _0x7f2c4f) / 1e18;
    }
}
