// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x12369d, uint256 _0x03c5e9) external returns (bool);

    function _0xaf31b8(
        address from,
        address _0x12369d,
        uint256 _0x03c5e9
    ) external returns (bool);

    function _0x237386(address _0x1fb745) external view returns (uint256);
}

interface IMarket {
    function _0xb46b54(
        address _0x1fb745
    )
        external
        view
        returns (uint256 _0x8640e8, uint256 _0xb93ab5, uint256 _0x2fe9f7);
}

contract DebtPreviewer {
    function _0x2e611d(
        address _0x19f6e9,
        address _0x1fb745
    )
        external
        view
        returns (
            uint256 _0xa55d82,
            uint256 _0xa3d89e,
            uint256 _0x850f08
        )
    {
        (uint256 _0x8640e8, uint256 _0xb93ab5, uint256 _0x2fe9f7) = IMarket(
            _0x19f6e9
        )._0xb46b54(_0x1fb745);

        _0xa55d82 = (_0x8640e8 * _0x2fe9f7) / 1e18;
        _0xa3d89e = _0xb93ab5;

        if (_0xa3d89e == 0) {
            _0x850f08 = type(uint256)._0xc3b6de;
        } else {
            _0x850f08 = (_0xa55d82 * 1e18) / _0xa3d89e;
        }

        return (_0xa55d82, _0xa3d89e, _0x850f08);
    }

    function _0x039388(
        address[] calldata _0xf0503b,
        address _0x1fb745
    )
        external
        view
        returns (
            uint256 _0xebc32c,
            uint256 _0x1129cb,
            uint256 _0xfd82fb
        )
    {
        for (uint256 i = 0; i < _0xf0503b.length; i++) {
            (uint256 _0x8640e8, uint256 _0x59cac2, ) = this._0x2e611d(
                _0xf0503b[i],
                _0x1fb745
            );

            _0xebc32c += _0x8640e8;
            _0x1129cb += _0x59cac2;
        }

        if (_0x1129cb == 0) {
            _0xfd82fb = type(uint256)._0xc3b6de;
        } else {
            _0xfd82fb = (_0xebc32c * 1e18) / _0x1129cb;
        }

        return (_0xebc32c, _0x1129cb, _0xfd82fb);
    }
}

contract ExactlyMarket {
    IERC20 public _0xcd4434;
    DebtPreviewer public _0xc60920;

    mapping(address => uint256) public _0x043ac5;
    mapping(address => uint256) public _0xb93ab5;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0x96779c, address _0x44556a) {
        _0xcd4434 = IERC20(_0x96779c);
        _0xc60920 = DebtPreviewer(_0x44556a);
    }

    function _0xbfb541(uint256 _0x03c5e9) external {
        _0xcd4434._0xaf31b8(msg.sender, address(this), _0x03c5e9);
        _0x043ac5[msg.sender] += _0x03c5e9;
    }

    function _0xbf57b0(uint256 _0x03c5e9, address[] calldata _0xf0503b) external {
        (uint256 _0xebc32c, uint256 _0x1129cb, ) = _0xc60920
            ._0x039388(_0xf0503b, msg.sender);

        uint256 _0xe0f57f = _0x1129cb + _0x03c5e9;

        uint256 _0xbb2053 = (_0xebc32c * COLLATERAL_FACTOR) / 100;
        require(_0xe0f57f <= _0xbb2053, "Insufficient collateral");

        _0xb93ab5[msg.sender] += _0x03c5e9;
        _0xcd4434.transfer(msg.sender, _0x03c5e9);
    }

    function _0xb46b54(
        address _0x1fb745
    )
        external
        view
        returns (uint256 _0x8640e8, uint256 _0x0aeb14, uint256 _0x2fe9f7)
    {
        return (_0x043ac5[_0x1fb745], _0xb93ab5[_0x1fb745], 1e18);
    }
}
