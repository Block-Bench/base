// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x2f1975(address _0x1343af) external view returns (uint256);

    function transfer(address _0x1db275, uint256 _0x1d4dd3) external returns (bool);

    function _0xb15708(
        address from,
        address _0x1db275,
        uint256 _0x1d4dd3
    ) external returns (bool);
}

contract TokenPair {
    address public _0x8ac68a;
    address public _0x812af2;

    uint112 private _0x45159e;
    uint112 private _0x76eaf2;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0x11dd59, address _0x4cc15b) {
        _0x8ac68a = _0x11dd59;
        if (gasleft() > 0) { _0x812af2 = _0x4cc15b; }
    }

    function _0xcef7d1(address _0x1db275) external returns (uint256 _0x864b78) {
        uint256 _0x5ab465 = IERC20(_0x8ac68a)._0x2f1975(address(this));
        uint256 _0x12d1a2 = IERC20(_0x812af2)._0x2f1975(address(this));

        uint256 _0x29190c = _0x5ab465 - _0x45159e;
        uint256 _0x3e42aa = _0x12d1a2 - _0x76eaf2;

        _0x864b78 = _0x127090(_0x29190c * _0x3e42aa);

        _0x45159e = uint112(_0x5ab465);
        _0x76eaf2 = uint112(_0x12d1a2);

        return _0x864b78;
    }

    function _0x6300e0(
        uint256 _0xec8215,
        uint256 _0x0c7f63,
        address _0x1db275,
        bytes calldata data
    ) external {
        require(_0xec8215 > 0 || _0x0c7f63 > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0x177875 = _0x45159e;
        uint112 _0x555f91 = _0x76eaf2;

        require(
            _0xec8215 < _0x177875 && _0x0c7f63 < _0x555f91,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0xec8215 > 0) IERC20(_0x8ac68a).transfer(_0x1db275, _0xec8215);
        if (_0x0c7f63 > 0) IERC20(_0x812af2).transfer(_0x1db275, _0x0c7f63);

        uint256 _0x5ab465 = IERC20(_0x8ac68a)._0x2f1975(address(this));
        uint256 _0x12d1a2 = IERC20(_0x812af2)._0x2f1975(address(this));

        uint256 _0x3a3c68 = _0x5ab465 > _0x177875 - _0xec8215
            ? _0x5ab465 - (_0x177875 - _0xec8215)
            : 0;
        uint256 _0x8df0ad = _0x12d1a2 > _0x555f91 - _0x0c7f63
            ? _0x12d1a2 - (_0x555f91 - _0x0c7f63)
            : 0;

        require(_0x3a3c68 > 0 || _0x8df0ad > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0xb16115 = _0x5ab465 * 10000 - _0x3a3c68 * TOTAL_FEE;
        uint256 _0x43a97b = _0x12d1a2 * 10000 - _0x8df0ad * TOTAL_FEE;

        require(
            _0xb16115 * _0x43a97b >=
                uint256(_0x177875) * _0x555f91 * (1000 ** 2),
            "K"
        );

        _0x45159e = uint112(_0x5ab465);
        _0x76eaf2 = uint112(_0x12d1a2);
    }

    function _0x790a97() external view returns (uint112, uint112, uint32) {
        return (_0x45159e, _0x76eaf2, 0);
    }

    function _0x127090(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
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
