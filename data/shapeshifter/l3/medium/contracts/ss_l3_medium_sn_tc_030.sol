// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidityPool {
    uint256 public _0x11e645;
    uint256 public _0x033db0;
    uint256 public _0x33e1ee;

    mapping(address => uint256) public _0x31979b;

    function _0x6181fe(uint256 _0xc75d46, uint256 _0xe50b49) external returns (uint256 _0xb95b9d) {

        if (_0x33e1ee == 0) {
            _0xb95b9d = _0xc75d46;
        } else {
            uint256 _0xd8765f = (_0xc75d46 * _0x33e1ee) / _0x11e645;
            uint256 _0xfccd2e = (_0xe50b49 * _0x33e1ee) / _0x033db0;

            _0xb95b9d = (_0xd8765f + _0xfccd2e) / 2;
        }

        _0x31979b[msg.sender] += _0xb95b9d;
        _0x33e1ee += _0xb95b9d;

        _0x11e645 += _0xc75d46;
        _0x033db0 += _0xe50b49;

        return _0xb95b9d;
    }

    function _0x7203a5(uint256 _0xb95b9d) external returns (uint256, uint256) {
        uint256 _0x03e60c = (_0xb95b9d * _0x11e645) / _0x33e1ee;
        uint256 _0x6bb29f = (_0xb95b9d * _0x033db0) / _0x33e1ee;

        _0x31979b[msg.sender] -= _0xb95b9d;
        _0x33e1ee -= _0xb95b9d;

        _0x11e645 -= _0x03e60c;
        _0x033db0 -= _0x6bb29f;

        return (_0x03e60c, _0x6bb29f);
    }
}
