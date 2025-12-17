// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function _0x8f4f73()
        external
        view
        returns (uint112 _0x08f6a4, uint112 _0x48c6b8, uint32 _0x200d6e);

    function _0x8a352c() external view returns (uint256);
}

interface IERC20 {
    function _0xe52a46(address _0xd0041a) external view returns (uint256);

    function transfer(address _0xc9792e, uint256 _0x514932) external returns (bool);

    function _0x74e916(
        address from,
        address _0xc9792e,
        uint256 _0x514932
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 _0x547b05;
        uint256 _0x13952a;
    }

    mapping(address => Position) public _0x010efb;

    address public _0x7505db;
    address public _0x43b392;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address _0xb94574, address _0x78004a) {
        _0x7505db = _0xb94574;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x43b392 = _0x78004a; }
    }

    function _0x83b76c(uint256 _0x514932) external {
        IERC20(_0x7505db)._0x74e916(msg.sender, address(this), _0x514932);
        _0x010efb[msg.sender]._0x547b05 += _0x514932;
    }

    function _0xc5c114(uint256 _0x514932) external {
        uint256 _0x14479d = _0xdc056f(
            _0x010efb[msg.sender]._0x547b05
        );
        uint256 _0x755ed8 = (_0x14479d * 100) / COLLATERAL_RATIO;

        require(
            _0x010efb[msg.sender]._0x13952a + _0x514932 <= _0x755ed8,
            "Insufficient collateral"
        );

        _0x010efb[msg.sender]._0x13952a += _0x514932;
        IERC20(_0x43b392).transfer(msg.sender, _0x514932);
    }

    function _0xdc056f(uint256 _0x401425) public view returns (uint256) {
        if (_0x401425 == 0) return 0;

        IUniswapV2Pair _0x8cd58c = IUniswapV2Pair(_0x7505db);

        (uint112 _0x08f6a4, uint112 _0x48c6b8, ) = _0x8cd58c._0x8f4f73();
        uint256 _0x8a352c = _0x8cd58c._0x8a352c();

        uint256 _0xb4f75f = (uint256(_0x08f6a4) * _0x401425) / _0x8a352c;
        uint256 _0x31c503 = (uint256(_0x48c6b8) * _0x401425) / _0x8a352c;

        uint256 _0x19455f = _0xb4f75f;
        uint256 _0xf7107b = _0xb4f75f + _0x31c503;

        return _0xf7107b;
    }

    function _0x7c0997(uint256 _0x514932) external {
        require(_0x010efb[msg.sender]._0x13952a >= _0x514932, "Repay exceeds debt");

        IERC20(_0x43b392)._0x74e916(msg.sender, address(this), _0x514932);
        _0x010efb[msg.sender]._0x13952a -= _0x514932;
    }

    function _0x1dd6d8(uint256 _0x514932) external {
        require(
            _0x010efb[msg.sender]._0x547b05 >= _0x514932,
            "Insufficient balance"
        );

        uint256 _0x93aeb1 = _0x010efb[msg.sender]._0x547b05 - _0x514932;
        uint256 _0xaae476 = _0xdc056f(_0x93aeb1);
        uint256 _0x755ed8 = (_0xaae476 * 100) / COLLATERAL_RATIO;

        require(
            _0x010efb[msg.sender]._0x13952a <= _0x755ed8,
            "Withdrawal would liquidate position"
        );

        _0x010efb[msg.sender]._0x547b05 -= _0x514932;
        IERC20(_0x7505db).transfer(msg.sender, _0x514932);
    }
}
