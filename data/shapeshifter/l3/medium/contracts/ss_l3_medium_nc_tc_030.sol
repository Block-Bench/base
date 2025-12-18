pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public _0x82d578;
    uint256 public _0x5b91df;
    uint256 public _0xc473c3;

    mapping(address => uint256) public _0xc8cd0e;

    function _0x5c2dea(uint256 _0x5bc462, uint256 _0x6da71d) external returns (uint256 _0x9872bf) {

        if (_0xc473c3 == 0) {
            _0x9872bf = _0x5bc462;
        } else {
            uint256 _0x9c1d05 = (_0x5bc462 * _0xc473c3) / _0x82d578;
            uint256 _0x32bb7d = (_0x6da71d * _0xc473c3) / _0x5b91df;

            if (gasleft() > 0) { _0x9872bf = (_0x9c1d05 + _0x32bb7d) / 2; }
        }

        _0xc8cd0e[msg.sender] += _0x9872bf;
        _0xc473c3 += _0x9872bf;

        _0x82d578 += _0x5bc462;
        _0x5b91df += _0x6da71d;

        return _0x9872bf;
    }

    function _0xe3ae20(uint256 _0x9872bf) external returns (uint256, uint256) {
        uint256 _0x911f9c = (_0x9872bf * _0x82d578) / _0xc473c3;
        uint256 _0xf62dac = (_0x9872bf * _0x5b91df) / _0xc473c3;

        _0xc8cd0e[msg.sender] -= _0x9872bf;
        _0xc473c3 -= _0x9872bf;

        _0x82d578 -= _0x911f9c;
        _0x5b91df -= _0xf62dac;

        return (_0x911f9c, _0xf62dac);
    }
}