pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public _0xb93bc5;
    uint256 public _0xaf5ed1;
    uint256 public _0x58e274;

    mapping(address => uint256) public _0x71962b;

    function _0x408983(uint256 _0xa73a63, uint256 _0xafdbbb) external returns (uint256 _0xe28fb2) {

        if (_0x58e274 == 0) {
            _0xe28fb2 = _0xa73a63;
        } else {
            uint256 _0xadecbb = (_0xa73a63 * _0x58e274) / _0xb93bc5;
            uint256 _0xc598f1 = (_0xafdbbb * _0x58e274) / _0xaf5ed1;

            _0xe28fb2 = (_0xadecbb + _0xc598f1) / 2;
        }

        _0x71962b[msg.sender] += _0xe28fb2;
        _0x58e274 += _0xe28fb2;

        _0xb93bc5 += _0xa73a63;
        _0xaf5ed1 += _0xafdbbb;

        return _0xe28fb2;
    }

    function _0x980b46(uint256 _0xe28fb2) external returns (uint256, uint256) {
        uint256 _0x39be9a = (_0xe28fb2 * _0xb93bc5) / _0x58e274;
        uint256 _0xedc399 = (_0xe28fb2 * _0xaf5ed1) / _0x58e274;

        _0x71962b[msg.sender] -= _0xe28fb2;
        _0x58e274 -= _0xe28fb2;

        _0xb93bc5 -= _0x39be9a;
        _0xaf5ed1 -= _0xedc399;

        return (_0x39be9a, _0xedc399);
    }
}