// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x2376bd(address _0x15029a) external view returns (uint256);

    function transfer(address _0x48ffdb, uint256 _0x56b4cc) external returns (bool);

    function _0xb709ee(
        address from,
        address _0x48ffdb,
        uint256 _0x56b4cc
    ) external returns (bool);
}

contract LiquidityPool {
    address public _0xc80039;
    address public _0xdee08d;
    address public _0xb0669e;

    uint256 public _0xba192f;
    uint256 public _0x37169c;
    uint256 public _0xd36cc3;

    bool public _0xd62c4e;

    event Initialized(address _0xc80039, address _0x141068, address _0x3cdc09);

    function _0x8af721(
        address _0x341e69,
        address _0xb9e7a6,
        address _0x07913f,
        uint256 _0x8ad402
    ) external {
        _0xc80039 = _0x341e69;
        _0xdee08d = _0xb9e7a6;
        _0xb0669e = _0x07913f;
        _0xba192f = _0x8ad402;

        _0xd62c4e = true;

        emit Initialized(_0x341e69, _0xb9e7a6, _0x07913f);
    }

    function _0xe849a3(uint256 _0xbd1d1e, uint256 _0xe6c53a) external {
        require(_0xd62c4e, "Not initialized");

        IERC20(_0xdee08d)._0xb709ee(msg.sender, address(this), _0xbd1d1e);
        IERC20(_0xb0669e)._0xb709ee(msg.sender, address(this), _0xe6c53a);

        _0x37169c += _0xbd1d1e;
        _0xd36cc3 += _0xe6c53a;
    }

    function _0xae8061(
        address _0x584f71,
        address _0x04ee45,
        uint256 _0x6b3d34
    ) external returns (uint256 _0x0b25a0) {
        require(_0xd62c4e, "Not initialized");
        require(
            (_0x584f71 == _0xdee08d && _0x04ee45 == _0xb0669e) ||
                (_0x584f71 == _0xb0669e && _0x04ee45 == _0xdee08d),
            "Invalid token pair"
        );

        IERC20(_0x584f71)._0xb709ee(msg.sender, address(this), _0x6b3d34);

        if (_0x584f71 == _0xdee08d) {
            _0x0b25a0 = (_0xd36cc3 * _0x6b3d34) / (_0x37169c + _0x6b3d34);
            _0x37169c += _0x6b3d34;
            _0xd36cc3 -= _0x0b25a0;
        } else {
            _0x0b25a0 = (_0x37169c * _0x6b3d34) / (_0xd36cc3 + _0x6b3d34);
            _0xd36cc3 += _0x6b3d34;
            _0x37169c -= _0x0b25a0;
        }

        uint256 _0xdadb20 = (_0x0b25a0 * _0xba192f) / 10000;
        _0x0b25a0 -= _0xdadb20;

        IERC20(_0x04ee45).transfer(msg.sender, _0x0b25a0);
        IERC20(_0x04ee45).transfer(_0xc80039, _0xdadb20);

        return _0x0b25a0;
    }

    function _0x3fad33() external {
        require(msg.sender == _0xc80039, "Only maintainer");

        uint256 _0xfb9e06 = IERC20(_0xdee08d)._0x2376bd(address(this));
        uint256 _0x418c9c = IERC20(_0xb0669e)._0x2376bd(address(this));

        if (_0xfb9e06 > _0x37169c) {
            uint256 _0x4e45bf = _0xfb9e06 - _0x37169c;
            IERC20(_0xdee08d).transfer(_0xc80039, _0x4e45bf);
        }

        if (_0x418c9c > _0xd36cc3) {
            uint256 _0x4e45bf = _0x418c9c - _0xd36cc3;
            IERC20(_0xb0669e).transfer(_0xc80039, _0x4e45bf);
        }
    }
}
