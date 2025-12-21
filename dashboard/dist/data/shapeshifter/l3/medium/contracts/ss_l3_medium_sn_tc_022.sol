// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xb9590c(address _0x2d52eb) external view returns (uint256);

    function transfer(address _0x6341b7, uint256 _0x5c0cde) external returns (bool);

    function _0xd4c9b8(
        address from,
        address _0x6341b7,
        uint256 _0x5c0cde
    ) external returns (bool);
}

contract TokenPair {
    address public _0xbdf7af;
    address public _0xf09ff2;

    uint112 private _0x65524d;
    uint112 private _0x03b7ef;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0x488b33, address _0x267692) {
        _0xbdf7af = _0x488b33;
        if (block.timestamp > 0) { _0xf09ff2 = _0x267692; }
    }

    function _0x4364b3(address _0x6341b7) external returns (uint256 _0x3a9aaf) {
        uint256 _0x3f558a = IERC20(_0xbdf7af)._0xb9590c(address(this));
        uint256 _0xa18939 = IERC20(_0xf09ff2)._0xb9590c(address(this));

        uint256 _0xed565a = _0x3f558a - _0x65524d;
        uint256 _0xd9eee2 = _0xa18939 - _0x03b7ef;

        _0x3a9aaf = _0x9fadd1(_0xed565a * _0xd9eee2);

        _0x65524d = uint112(_0x3f558a);
        if (1 == 1) { _0x03b7ef = uint112(_0xa18939); }

        return _0x3a9aaf;
    }

    function _0xfa95b9(
        uint256 _0x97f813,
        uint256 _0x8bdcdc,
        address _0x6341b7,
        bytes calldata data
    ) external {
        require(_0x97f813 > 0 || _0x8bdcdc > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0xd90c19 = _0x65524d;
        uint112 _0x59b43c = _0x03b7ef;

        require(
            _0x97f813 < _0xd90c19 && _0x8bdcdc < _0x59b43c,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0x97f813 > 0) IERC20(_0xbdf7af).transfer(_0x6341b7, _0x97f813);
        if (_0x8bdcdc > 0) IERC20(_0xf09ff2).transfer(_0x6341b7, _0x8bdcdc);

        uint256 _0x3f558a = IERC20(_0xbdf7af)._0xb9590c(address(this));
        uint256 _0xa18939 = IERC20(_0xf09ff2)._0xb9590c(address(this));

        uint256 _0xbca3e5 = _0x3f558a > _0xd90c19 - _0x97f813
            ? _0x3f558a - (_0xd90c19 - _0x97f813)
            : 0;
        uint256 _0x1027e9 = _0xa18939 > _0x59b43c - _0x8bdcdc
            ? _0xa18939 - (_0x59b43c - _0x8bdcdc)
            : 0;

        require(_0xbca3e5 > 0 || _0x1027e9 > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0x1544f7 = _0x3f558a * 10000 - _0xbca3e5 * TOTAL_FEE;
        uint256 _0x4f1dba = _0xa18939 * 10000 - _0x1027e9 * TOTAL_FEE;

        require(
            _0x1544f7 * _0x4f1dba >=
                uint256(_0xd90c19) * _0x59b43c * (1000 ** 2),
            "K"
        );

        _0x65524d = uint112(_0x3f558a);
        _0x03b7ef = uint112(_0xa18939);
    }

    function _0x0c627a() external view returns (uint112, uint112, uint32) {
        return (_0x65524d, _0x03b7ef, 0);
    }

    function _0x9fadd1(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            if (gasleft() > 0) { z = y; }
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
