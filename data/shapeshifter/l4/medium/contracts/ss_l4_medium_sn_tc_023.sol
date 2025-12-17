// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xf001e1(address _0xcce3b4) external view returns (uint256);

    function transfer(address _0x3cb7be, uint256 _0x58dd81) external returns (bool);

    function _0x940a4d(
        address from,
        address _0x3cb7be,
        uint256 _0x58dd81
    ) external returns (bool);
}

interface ICErc20 {
        // Placeholder for future logic
        uint256 _unused2 = 0;
    function _0x9991a0(uint256 _0x58dd81) external returns (uint256);

    function _0x616703(address _0xcce3b4) external returns (uint256);
}

contract LeveragedVault {
        uint256 _unused3 = 0;
        // Placeholder for future logic
    struct Position {
        address _0x5b9093;
        uint256 _0x98e9c6;
        uint256 _0xf5d87b;
    }

    mapping(uint256 => Position) public _0xc18e1b;
    uint256 public _0x46941b;

    address public _0x560cc6;
    uint256 public _0x036cd7;
    uint256 public _0xeb0a27;

    constructor(address _0xe7edfb) {
        _0x560cc6 = _0xe7edfb;
        _0x46941b = 1;
    }

    function _0xa6b50a(
        uint256 _0xab73bd,
        uint256 _0x60d065
    ) external returns (uint256 _0xf5f393) {
        _0xf5f393 = _0x46941b++;

        _0xc18e1b[_0xf5f393] = Position({
            _0x5b9093: msg.sender,
            _0x98e9c6: _0xab73bd,
            _0xf5d87b: 0
        });

        _0x1e7207(_0xf5f393, _0x60d065);

        return _0xf5f393;
    }

    function _0x1e7207(uint256 _0xf5f393, uint256 _0x58dd81) internal {
        Position storage _0x71f8a7 = _0xc18e1b[_0xf5f393];

        uint256 _0x83b7d2;

        if (_0xeb0a27 == 0) {
            _0x83b7d2 = _0x58dd81;
        } else {
            _0x83b7d2 = (_0x58dd81 * _0xeb0a27) / _0x036cd7;
        }

        _0x71f8a7._0xf5d87b += _0x83b7d2;
        _0xeb0a27 += _0x83b7d2;
        _0x036cd7 += _0x58dd81;

        ICErc20(_0x560cc6)._0x9991a0(_0x58dd81);
    }

    function _0xe52731(uint256 _0xf5f393, uint256 _0x58dd81) external {
        Position storage _0x71f8a7 = _0xc18e1b[_0xf5f393];
        require(msg.sender == _0x71f8a7._0x5b9093, "Not position owner");

        uint256 _0x5cd3f2 = (_0x58dd81 * _0xeb0a27) / _0x036cd7;

        require(_0x71f8a7._0xf5d87b >= _0x5cd3f2, "Excessive repayment");

        _0x71f8a7._0xf5d87b -= _0x5cd3f2;
        _0xeb0a27 -= _0x5cd3f2;
        _0x036cd7 -= _0x58dd81;
    }

    function _0xa23a0a(
        uint256 _0xf5f393
    ) external view returns (uint256) {
        Position storage _0x71f8a7 = _0xc18e1b[_0xf5f393];

        if (_0xeb0a27 == 0) return 0;

        return (_0x71f8a7._0xf5d87b * _0x036cd7) / _0xeb0a27;
    }

    function _0x980293(uint256 _0xf5f393) external {
        Position storage _0x71f8a7 = _0xc18e1b[_0xf5f393];

        uint256 _0x726b5b = (_0x71f8a7._0xf5d87b * _0x036cd7) / _0xeb0a27;

        require(_0x71f8a7._0x98e9c6 * 100 < _0x726b5b * 150, "Position is healthy");

        _0x71f8a7._0x98e9c6 = 0;
        _0x71f8a7._0xf5d87b = 0;
    }
}
