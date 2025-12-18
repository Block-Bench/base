// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function _0x1d2bba(address _0x55c78b) external view returns (uint256);

    function transfer(address _0xc25db9, uint256 _0x6872a4) external returns (bool);

    function _0x90dad9(
        address from,
        address _0xc25db9,
        uint256 _0x6872a4
    ) external returns (bool);
}

interface ICurvePool {
    function _0xacdd31() external view returns (uint256);

    function _0x33a702(
        uint256[3] calldata _0x862e70,
        uint256 _0x7c53f9
    ) external;
}

contract PriceOracle {
    ICurvePool public _0x7ae6ad;

    constructor(address _0x87cfd0) {
        _0x7ae6ad = ICurvePool(_0x87cfd0);
    }

    function _0xe1aced() external view returns (uint256) {
        return _0x7ae6ad._0xacdd31();
    }
}

contract LendingProtocol {
    struct Position {
        uint256 _0x381809;
        uint256 _0x503a17;
    }

    mapping(address => Position) public _0xf7aef0;

    address public _0x1bca88;
    address public _0x50eea2;
    address public _0x2107a2;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(
        address _0xf5e7c5,
        address _0xbeb65a,
        address _0x303853
    ) {
        _0x1bca88 = _0xf5e7c5;
        _0x50eea2 = _0xbeb65a;
        _0x2107a2 = _0x303853;
    }

    function _0xa046e7(uint256 _0x6872a4) external {
        IERC20(_0x1bca88)._0x90dad9(msg.sender, address(this), _0x6872a4);
        _0xf7aef0[msg.sender]._0x381809 += _0x6872a4;
    }

    function _0x717f15(uint256 _0x6872a4) external {
        uint256 _0x101d76 = _0x12a94c(msg.sender);
        uint256 _0x957290 = (_0x101d76 * COLLATERAL_FACTOR) / 100;

        require(
            _0xf7aef0[msg.sender]._0x503a17 + _0x6872a4 <= _0x957290,
            "Insufficient collateral"
        );

        _0xf7aef0[msg.sender]._0x503a17 += _0x6872a4;
        IERC20(_0x50eea2).transfer(msg.sender, _0x6872a4);
    }

    function _0x12a94c(address _0xc16200) public view returns (uint256) {
        uint256 _0xd04cd8 = _0xf7aef0[_0xc16200]._0x381809;
        uint256 _0x16d612 = PriceOracle(_0x2107a2)._0xe1aced();

        return (_0xd04cd8 * _0x16d612) / 1e18;
    }
}
