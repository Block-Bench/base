// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function _0x77fd3f()
        external
        view
        returns (uint112 _0x8b0b23, uint112 _0xd59a02, uint32 _0xa384c1);

    function _0xe78417() external view returns (uint256);
}

interface IERC20 {
    function _0xbc78a3(address _0x1ae63f) external view returns (uint256);

    function transfer(address _0x1f985e, uint256 _0x6a0ff0) external returns (bool);

    function _0xe7eb68(
        address from,
        address _0x1f985e,
        uint256 _0x6a0ff0
    ) external returns (bool);
}

contract LendingVault {
    struct Position {
        uint256 _0xd51d82;
        uint256 _0xed95fc;
    }

    mapping(address => Position) public _0xb35ea7;

    address public _0x2ca7c1;
    address public _0x9439b3;
    uint256 public constant COLLATERAL_RATIO = 150;

    constructor(address _0x71f123, address _0xab2fe1) {
        _0x2ca7c1 = _0x71f123;
        _0x9439b3 = _0xab2fe1;
    }

    function _0x7dd3be(uint256 _0x6a0ff0) external {
        IERC20(_0x2ca7c1)._0xe7eb68(msg.sender, address(this), _0x6a0ff0);
        _0xb35ea7[msg.sender]._0xd51d82 += _0x6a0ff0;
    }

    function _0xb12ef0(uint256 _0x6a0ff0) external {
        uint256 _0x6ca0c8 = _0xa9a81f(
            _0xb35ea7[msg.sender]._0xd51d82
        );
        uint256 _0x6b16a7 = (_0x6ca0c8 * 100) / COLLATERAL_RATIO;

        require(
            _0xb35ea7[msg.sender]._0xed95fc + _0x6a0ff0 <= _0x6b16a7,
            "Insufficient collateral"
        );

        _0xb35ea7[msg.sender]._0xed95fc += _0x6a0ff0;
        IERC20(_0x9439b3).transfer(msg.sender, _0x6a0ff0);
    }

    function _0xa9a81f(uint256 _0x6105aa) public view returns (uint256) {
        if (_0x6105aa == 0) return 0;

        IUniswapV2Pair _0x6d9ec1 = IUniswapV2Pair(_0x2ca7c1);

        (uint112 _0x8b0b23, uint112 _0xd59a02, ) = _0x6d9ec1._0x77fd3f();
        uint256 _0xe78417 = _0x6d9ec1._0xe78417();

        uint256 _0x223f49 = (uint256(_0x8b0b23) * _0x6105aa) / _0xe78417;
        uint256 _0xaf17af = (uint256(_0xd59a02) * _0x6105aa) / _0xe78417;

        uint256 _0x1f5650 = _0x223f49;
        uint256 _0xc3c401 = _0x223f49 + _0xaf17af;

        return _0xc3c401;
    }

    function _0x06f3b4(uint256 _0x6a0ff0) external {
        require(_0xb35ea7[msg.sender]._0xed95fc >= _0x6a0ff0, "Repay exceeds debt");

        IERC20(_0x9439b3)._0xe7eb68(msg.sender, address(this), _0x6a0ff0);
        _0xb35ea7[msg.sender]._0xed95fc -= _0x6a0ff0;
    }

    function _0xee18ad(uint256 _0x6a0ff0) external {
        require(
            _0xb35ea7[msg.sender]._0xd51d82 >= _0x6a0ff0,
            "Insufficient balance"
        );

        uint256 _0x57d9a8 = _0xb35ea7[msg.sender]._0xd51d82 - _0x6a0ff0;
        uint256 _0x5b6f6e = _0xa9a81f(_0x57d9a8);
        uint256 _0x6b16a7 = (_0x5b6f6e * 100) / COLLATERAL_RATIO;

        require(
            _0xb35ea7[msg.sender]._0xed95fc <= _0x6b16a7,
            "Withdrawal would liquidate position"
        );

        _0xb35ea7[msg.sender]._0xd51d82 -= _0x6a0ff0;
        IERC20(_0x2ca7c1).transfer(msg.sender, _0x6a0ff0);
    }
}
