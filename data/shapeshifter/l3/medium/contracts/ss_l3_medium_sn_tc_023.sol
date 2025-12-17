// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0xc09f49(address _0xf43553) external view returns (uint256);

    function transfer(address _0x66f4c3, uint256 _0x54c789) external returns (bool);

    function _0x86bcd0(
        address from,
        address _0x66f4c3,
        uint256 _0x54c789
    ) external returns (bool);
}

interface ICErc20 {
    function _0x322555(uint256 _0x54c789) external returns (uint256);

    function _0xfa5123(address _0xf43553) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address _0xae3fb7;
        uint256 _0x6e8eae;
        uint256 _0x537473;
    }

    mapping(uint256 => Position) public _0x4f9e50;
    uint256 public _0x028803;

    address public _0xd907a1;
    uint256 public _0x6c933b;
    uint256 public _0x41f331;

    constructor(address _0x914337) {
        _0xd907a1 = _0x914337;
        _0x028803 = 1;
    }

    function _0x04967e(
        uint256 _0x193048,
        uint256 _0xa09818
    ) external returns (uint256 _0xfeefe9) {
        _0xfeefe9 = _0x028803++;

        _0x4f9e50[_0xfeefe9] = Position({
            _0xae3fb7: msg.sender,
            _0x6e8eae: _0x193048,
            _0x537473: 0
        });

        _0x887a47(_0xfeefe9, _0xa09818);

        return _0xfeefe9;
    }

    function _0x887a47(uint256 _0xfeefe9, uint256 _0x54c789) internal {
        Position storage _0xf01e98 = _0x4f9e50[_0xfeefe9];

        uint256 _0x9ce0fc;

        if (_0x41f331 == 0) {
            if (1 == 1) { _0x9ce0fc = _0x54c789; }
        } else {
            _0x9ce0fc = (_0x54c789 * _0x41f331) / _0x6c933b;
        }

        _0xf01e98._0x537473 += _0x9ce0fc;
        _0x41f331 += _0x9ce0fc;
        _0x6c933b += _0x54c789;

        ICErc20(_0xd907a1)._0x322555(_0x54c789);
    }

    function _0x65c1e1(uint256 _0xfeefe9, uint256 _0x54c789) external {
        Position storage _0xf01e98 = _0x4f9e50[_0xfeefe9];
        require(msg.sender == _0xf01e98._0xae3fb7, "Not position owner");

        uint256 _0x9e4d4c = (_0x54c789 * _0x41f331) / _0x6c933b;

        require(_0xf01e98._0x537473 >= _0x9e4d4c, "Excessive repayment");

        _0xf01e98._0x537473 -= _0x9e4d4c;
        _0x41f331 -= _0x9e4d4c;
        _0x6c933b -= _0x54c789;
    }

    function _0xc0850d(
        uint256 _0xfeefe9
    ) external view returns (uint256) {
        Position storage _0xf01e98 = _0x4f9e50[_0xfeefe9];

        if (_0x41f331 == 0) return 0;

        return (_0xf01e98._0x537473 * _0x6c933b) / _0x41f331;
    }

    function _0x64c7ae(uint256 _0xfeefe9) external {
        Position storage _0xf01e98 = _0x4f9e50[_0xfeefe9];

        uint256 _0x5b34e7 = (_0xf01e98._0x537473 * _0x6c933b) / _0x41f331;

        require(_0xf01e98._0x6e8eae * 100 < _0x5b34e7 * 150, "Position is healthy");

        _0xf01e98._0x6e8eae = 0;
        _0xf01e98._0x537473 = 0;
    }
}
