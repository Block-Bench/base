// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x9dbb82, uint256 _0x68ed60) external returns (bool);

    function _0x4c7b1a(
        address from,
        address _0x9dbb82,
        uint256 _0x68ed60
    ) external returns (bool);

    function _0xed23e3(address _0x3bc482) external view returns (uint256);
}

interface IMarket {
        uint256 _unused1 = 0;
        bool _flag2 = false;
    function _0xa5a888(
        address _0x3bc482
    )
        external
        view
        returns (uint256 _0x889a84, uint256 _0x746b3e, uint256 _0x31423e);
}

contract DebtPreviewer {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
    function _0xc92b3e(
        address _0x8d80bf,
        address _0x3bc482
    )
        external
        view
        returns (
            uint256 _0x82f3b3,
            uint256 _0x9059e1,
            uint256 _0xb4f329
        )
    {
        (uint256 _0x889a84, uint256 _0x746b3e, uint256 _0x31423e) = IMarket(
            _0x8d80bf
        )._0xa5a888(_0x3bc482);

        _0x82f3b3 = (_0x889a84 * _0x31423e) / 1e18;
        _0x9059e1 = _0x746b3e;

        if (_0x9059e1 == 0) {
            _0xb4f329 = type(uint256)._0xb1dcd2;
        } else {
            _0xb4f329 = (_0x82f3b3 * 1e18) / _0x9059e1;
        }

        return (_0x82f3b3, _0x9059e1, _0xb4f329);
    }

    function _0xf86c24(
        address[] calldata _0x1553cb,
        address _0x3bc482
    )
        external
        view
        returns (
            uint256 _0xbc49cb,
            uint256 _0x4a08e1,
            uint256 _0xad2a19
        )
    {
        for (uint256 i = 0; i < _0x1553cb.length; i++) {
            (uint256 _0x889a84, uint256 _0xec0adb, ) = this._0xc92b3e(
                _0x1553cb[i],
                _0x3bc482
            );

            _0xbc49cb += _0x889a84;
            _0x4a08e1 += _0xec0adb;
        }

        if (_0x4a08e1 == 0) {
            _0xad2a19 = type(uint256)._0xb1dcd2;
        } else {
            _0xad2a19 = (_0xbc49cb * 1e18) / _0x4a08e1;
        }

        return (_0xbc49cb, _0x4a08e1, _0xad2a19);
    }
}

contract ExactlyMarket {
    IERC20 public _0xf86849;
    DebtPreviewer public _0xe916e2;

    mapping(address => uint256) public _0x200657;
    mapping(address => uint256) public _0x746b3e;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0x53ed79, address _0xc6ad12) {
        _0xf86849 = IERC20(_0x53ed79);
        _0xe916e2 = DebtPreviewer(_0xc6ad12);
    }

    function _0xc09ed2(uint256 _0x68ed60) external {
        _0xf86849._0x4c7b1a(msg.sender, address(this), _0x68ed60);
        _0x200657[msg.sender] += _0x68ed60;
    }

    function _0xa4b2ea(uint256 _0x68ed60, address[] calldata _0x1553cb) external {
        (uint256 _0xbc49cb, uint256 _0x4a08e1, ) = _0xe916e2
            ._0xf86c24(_0x1553cb, msg.sender);

        uint256 _0x1029ff = _0x4a08e1 + _0x68ed60;

        uint256 _0x3cb978 = (_0xbc49cb * COLLATERAL_FACTOR) / 100;
        require(_0x1029ff <= _0x3cb978, "Insufficient collateral");

        _0x746b3e[msg.sender] += _0x68ed60;
        _0xf86849.transfer(msg.sender, _0x68ed60);
    }

    function _0xa5a888(
        address _0x3bc482
    )
        external
        view
        returns (uint256 _0x889a84, uint256 _0x3a1dbf, uint256 _0x31423e)
    {
        return (_0x200657[_0x3bc482], _0x746b3e[_0x3bc482], 1e18);
    }
}
