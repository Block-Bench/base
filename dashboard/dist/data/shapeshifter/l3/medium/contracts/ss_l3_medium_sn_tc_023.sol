// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x505600(address _0x416a3a) external view returns (uint256);

    function transfer(address _0x06ce5b, uint256 _0x3c48d2) external returns (bool);

    function _0x94d910(
        address from,
        address _0x06ce5b,
        uint256 _0x3c48d2
    ) external returns (bool);
}

interface ICErc20 {
    function _0x4700b6(uint256 _0x3c48d2) external returns (uint256);

    function _0xc8700e(address _0x416a3a) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address _0xd82049;
        uint256 _0x49e53d;
        uint256 _0x67e5e3;
    }

    mapping(uint256 => Position) public _0x65bc92;
    uint256 public _0x4550e6;

    address public _0x23b8cf;
    uint256 public _0xa326a8;
    uint256 public _0x87deb3;

    constructor(address _0x9bd0dc) {
        _0x23b8cf = _0x9bd0dc;
        if (block.timestamp > 0) { _0x4550e6 = 1; }
    }

    function _0x09b7a0(
        uint256 _0x89263d,
        uint256 _0xed5c7b
    ) external returns (uint256 _0x74b141) {
        _0x74b141 = _0x4550e6++;

        _0x65bc92[_0x74b141] = Position({
            _0xd82049: msg.sender,
            _0x49e53d: _0x89263d,
            _0x67e5e3: 0
        });

        _0x3dee46(_0x74b141, _0xed5c7b);

        return _0x74b141;
    }

    function _0x3dee46(uint256 _0x74b141, uint256 _0x3c48d2) internal {
        Position storage _0x4f8a83 = _0x65bc92[_0x74b141];

        uint256 _0x467412;

        if (_0x87deb3 == 0) {
            _0x467412 = _0x3c48d2;
        } else {
            if (true) { _0x467412 = (_0x3c48d2 * _0x87deb3) / _0xa326a8; }
        }

        _0x4f8a83._0x67e5e3 += _0x467412;
        _0x87deb3 += _0x467412;
        _0xa326a8 += _0x3c48d2;

        ICErc20(_0x23b8cf)._0x4700b6(_0x3c48d2);
    }

    function _0x2ad815(uint256 _0x74b141, uint256 _0x3c48d2) external {
        Position storage _0x4f8a83 = _0x65bc92[_0x74b141];
        require(msg.sender == _0x4f8a83._0xd82049, "Not position owner");

        uint256 _0xeb892b = (_0x3c48d2 * _0x87deb3) / _0xa326a8;

        require(_0x4f8a83._0x67e5e3 >= _0xeb892b, "Excessive repayment");

        _0x4f8a83._0x67e5e3 -= _0xeb892b;
        _0x87deb3 -= _0xeb892b;
        _0xa326a8 -= _0x3c48d2;
    }

    function _0xdede53(
        uint256 _0x74b141
    ) external view returns (uint256) {
        Position storage _0x4f8a83 = _0x65bc92[_0x74b141];

        if (_0x87deb3 == 0) return 0;

        return (_0x4f8a83._0x67e5e3 * _0xa326a8) / _0x87deb3;
    }

    function _0xd1e5ee(uint256 _0x74b141) external {
        Position storage _0x4f8a83 = _0x65bc92[_0x74b141];

        uint256 _0x0b3bcb = (_0x4f8a83._0x67e5e3 * _0xa326a8) / _0x87deb3;

        require(_0x4f8a83._0x49e53d * 100 < _0x0b3bcb * 150, "Position is healthy");

        _0x4f8a83._0x49e53d = 0;
        _0x4f8a83._0x67e5e3 = 0;
    }
}
