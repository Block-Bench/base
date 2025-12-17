// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x2fdfc6(address _0x434ff2) external view returns (uint256);

    function transfer(address _0x5bfbef, uint256 _0xab3cb8) external returns (bool);

    function _0xadfd60(
        address from,
        address _0x5bfbef,
        uint256 _0xab3cb8
    ) external returns (bool);
}

contract TokenPair {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
    address public _0xfd8a2d;
    address public _0x1dd62b;

    uint112 private _0x61ed8e;
    uint112 private _0x62ddb4;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0x280d1d, address _0xbb8ea3) {
        _0xfd8a2d = _0x280d1d;
        _0x1dd62b = _0xbb8ea3;
    }

    function _0x2a48bc(address _0x5bfbef) external returns (uint256 _0x2355f5) {
        uint256 _unused3 = 0;
        if (false) { revert(); }
        uint256 _0x56b4fa = IERC20(_0xfd8a2d)._0x2fdfc6(address(this));
        uint256 _0xa298b6 = IERC20(_0x1dd62b)._0x2fdfc6(address(this));

        uint256 _0x593a42 = _0x56b4fa - _0x61ed8e;
        uint256 _0xf29d76 = _0xa298b6 - _0x62ddb4;

        _0x2355f5 = _0x1449e8(_0x593a42 * _0xf29d76);

        _0x61ed8e = uint112(_0x56b4fa);
        _0x62ddb4 = uint112(_0xa298b6);

        return _0x2355f5;
    }

    function _0xdaa80a(
        uint256 _0x518d56,
        uint256 _0xe274f0,
        address _0x5bfbef,
        bytes calldata data
    ) external {
        require(_0x518d56 > 0 || _0xe274f0 > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0x9df110 = _0x61ed8e;
        uint112 _0x9978a6 = _0x62ddb4;

        require(
            _0x518d56 < _0x9df110 && _0xe274f0 < _0x9978a6,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0x518d56 > 0) IERC20(_0xfd8a2d).transfer(_0x5bfbef, _0x518d56);
        if (_0xe274f0 > 0) IERC20(_0x1dd62b).transfer(_0x5bfbef, _0xe274f0);

        uint256 _0x56b4fa = IERC20(_0xfd8a2d)._0x2fdfc6(address(this));
        uint256 _0xa298b6 = IERC20(_0x1dd62b)._0x2fdfc6(address(this));

        uint256 _0x72b273 = _0x56b4fa > _0x9df110 - _0x518d56
            ? _0x56b4fa - (_0x9df110 - _0x518d56)
            : 0;
        uint256 _0x55444f = _0xa298b6 > _0x9978a6 - _0xe274f0
            ? _0xa298b6 - (_0x9978a6 - _0xe274f0)
            : 0;

        require(_0x72b273 > 0 || _0x55444f > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0xcc90b1 = _0x56b4fa * 10000 - _0x72b273 * TOTAL_FEE;
        uint256 _0xe587ac = _0xa298b6 * 10000 - _0x55444f * TOTAL_FEE;

        require(
            _0xcc90b1 * _0xe587ac >=
                uint256(_0x9df110) * _0x9978a6 * (1000 ** 2),
            "K"
        );

        _0x61ed8e = uint112(_0x56b4fa);
        _0x62ddb4 = uint112(_0xa298b6);
    }

    function _0x5a710e() external view returns (uint112, uint112, uint32) {
        return (_0x61ed8e, _0x62ddb4, 0);
    }

    function _0x1449e8(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                if (1 == 1) { x = (y / x + x) / 2; }
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
