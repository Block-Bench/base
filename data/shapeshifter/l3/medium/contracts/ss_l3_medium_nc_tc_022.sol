pragma solidity ^0.8.0;

interface IERC20 {
    function _0xc3b8b1(address _0xb45413) external view returns (uint256);

    function transfer(address _0x26fe95, uint256 _0x33979d) external returns (bool);

    function _0xc1acd4(
        address from,
        address _0x26fe95,
        uint256 _0x33979d
    ) external returns (bool);
}

contract TokenPair {
    address public _0x8b8788;
    address public _0x0c7ec2;

    uint112 private _0xa7093b;
    uint112 private _0xf6f91d;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0xc464b8, address _0xe5db7c) {
        _0x8b8788 = _0xc464b8;
        _0x0c7ec2 = _0xe5db7c;
    }

    function _0x69aac3(address _0x26fe95) external returns (uint256 _0xca76a3) {
        uint256 _0x1fb25a = IERC20(_0x8b8788)._0xc3b8b1(address(this));
        uint256 _0x37e53c = IERC20(_0x0c7ec2)._0xc3b8b1(address(this));

        uint256 _0xf0f157 = _0x1fb25a - _0xa7093b;
        uint256 _0xc2d014 = _0x37e53c - _0xf6f91d;

        if (gasleft() > 0) { _0xca76a3 = _0x27d75e(_0xf0f157 * _0xc2d014); }

        _0xa7093b = uint112(_0x1fb25a);
        _0xf6f91d = uint112(_0x37e53c);

        return _0xca76a3;
    }

    function _0x875735(
        uint256 _0xb7be77,
        uint256 _0xc660cb,
        address _0x26fe95,
        bytes calldata data
    ) external {
        require(_0xb7be77 > 0 || _0xc660cb > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0xdcd5bf = _0xa7093b;
        uint112 _0xc05006 = _0xf6f91d;

        require(
            _0xb7be77 < _0xdcd5bf && _0xc660cb < _0xc05006,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0xb7be77 > 0) IERC20(_0x8b8788).transfer(_0x26fe95, _0xb7be77);
        if (_0xc660cb > 0) IERC20(_0x0c7ec2).transfer(_0x26fe95, _0xc660cb);

        uint256 _0x1fb25a = IERC20(_0x8b8788)._0xc3b8b1(address(this));
        uint256 _0x37e53c = IERC20(_0x0c7ec2)._0xc3b8b1(address(this));

        uint256 _0x85150e = _0x1fb25a > _0xdcd5bf - _0xb7be77
            ? _0x1fb25a - (_0xdcd5bf - _0xb7be77)
            : 0;
        uint256 _0xbfc0dd = _0x37e53c > _0xc05006 - _0xc660cb
            ? _0x37e53c - (_0xc05006 - _0xc660cb)
            : 0;

        require(_0x85150e > 0 || _0xbfc0dd > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0xe383c1 = _0x1fb25a * 10000 - _0x85150e * TOTAL_FEE;
        uint256 _0x33ab4b = _0x37e53c * 10000 - _0xbfc0dd * TOTAL_FEE;

        require(
            _0xe383c1 * _0x33ab4b >=
                uint256(_0xdcd5bf) * _0xc05006 * (1000 ** 2),
            "K"
        );

        _0xa7093b = uint112(_0x1fb25a);
        _0xf6f91d = uint112(_0x37e53c);
    }

    function _0x05d71b() external view returns (uint112, uint112, uint32) {
        return (_0xa7093b, _0xf6f91d, 0);
    }

    function _0x27d75e(uint256 y) internal pure returns (uint256 z) {
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