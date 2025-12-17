// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x75b683, uint256 _0xea7ff8) external returns (bool);

    function _0xb25665(
        address from,
        address _0x75b683,
        uint256 _0xea7ff8
    ) external returns (bool);

    function _0x35a0a3(address _0xebe82a) external view returns (uint256);
}

interface IMarket {
    function _0x07f2c2(
        address _0xebe82a
    )
        external
        view
        returns (uint256 _0xa1dac4, uint256 _0x6ff98b, uint256 _0xd91183);
}

contract DebtPreviewer {
    function _0xbdfb7b(
        address _0x651330,
        address _0xebe82a
    )
        external
        view
        returns (
            uint256 _0x9150cb,
            uint256 _0xe89c79,
            uint256 _0xdfed42
        )
    {
        (uint256 _0xa1dac4, uint256 _0x6ff98b, uint256 _0xd91183) = IMarket(
            _0x651330
        )._0x07f2c2(_0xebe82a);

        _0x9150cb = (_0xa1dac4 * _0xd91183) / 1e18;
        _0xe89c79 = _0x6ff98b;

        if (_0xe89c79 == 0) {
            _0xdfed42 = type(uint256)._0xac2f1a;
        } else {
            _0xdfed42 = (_0x9150cb * 1e18) / _0xe89c79;
        }

        return (_0x9150cb, _0xe89c79, _0xdfed42);
    }

    function _0x419852(
        address[] calldata _0x0e28a9,
        address _0xebe82a
    )
        external
        view
        returns (
            uint256 _0x6703d2,
            uint256 _0x7ab4f5,
            uint256 _0xeaf811
        )
    {
        for (uint256 i = 0; i < _0x0e28a9.length; i++) {
            (uint256 _0xa1dac4, uint256 _0xa3a662, ) = this._0xbdfb7b(
                _0x0e28a9[i],
                _0xebe82a
            );

            _0x6703d2 += _0xa1dac4;
            _0x7ab4f5 += _0xa3a662;
        }

        if (_0x7ab4f5 == 0) {
            _0xeaf811 = type(uint256)._0xac2f1a;
        } else {
            _0xeaf811 = (_0x6703d2 * 1e18) / _0x7ab4f5;
        }

        return (_0x6703d2, _0x7ab4f5, _0xeaf811);
    }
}

contract ExactlyMarket {
    IERC20 public _0x12711f;
    DebtPreviewer public _0xa9ae54;

    mapping(address => uint256) public _0x5738af;
    mapping(address => uint256) public _0x6ff98b;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0xf73b12, address _0x5e0db3) {
        _0x12711f = IERC20(_0xf73b12);
        _0xa9ae54 = DebtPreviewer(_0x5e0db3);
    }

    function _0xfe578a(uint256 _0xea7ff8) external {
        _0x12711f._0xb25665(msg.sender, address(this), _0xea7ff8);
        _0x5738af[msg.sender] += _0xea7ff8;
    }

    function _0xf92b1f(uint256 _0xea7ff8, address[] calldata _0x0e28a9) external {
        (uint256 _0x6703d2, uint256 _0x7ab4f5, ) = _0xa9ae54
            ._0x419852(_0x0e28a9, msg.sender);

        uint256 _0x4657d0 = _0x7ab4f5 + _0xea7ff8;

        uint256 _0x135ef1 = (_0x6703d2 * COLLATERAL_FACTOR) / 100;
        require(_0x4657d0 <= _0x135ef1, "Insufficient collateral");

        _0x6ff98b[msg.sender] += _0xea7ff8;
        _0x12711f.transfer(msg.sender, _0xea7ff8);
    }

    function _0x07f2c2(
        address _0xebe82a
    )
        external
        view
        returns (uint256 _0xa1dac4, uint256 _0x187cfe, uint256 _0xd91183)
    {
        return (_0x5738af[_0xebe82a], _0x6ff98b[_0xebe82a], 1e18);
    }
}
