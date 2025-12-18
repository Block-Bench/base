// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function _0x52738e(
        uint256[3] memory _0xb59ef7,
        uint256 _0x50260e
    ) external;

    function _0xe65af3(
        uint256[3] memory _0xb59ef7,
        uint256 _0x8bb0dc
    ) external;

    function _0x510989() external view returns (uint256);
}

interface IERC20 {
    function transfer(address _0x8b8298, uint256 _0x639e95) external returns (bool);

    function _0xf78cff(
        address from,
        address _0x8b8298,
        uint256 _0x639e95
    ) external returns (bool);

    function _0x834dcb(address _0x8ca2f4) external view returns (uint256);

    function _0x479010(address _0x6a5170, uint256 _0x639e95) external returns (bool);
}

contract YieldVault {
    IERC20 public _0x787585;
    IERC20 public _0x4d1e4d;
    ICurve3Pool public _0x6f8806;

    mapping(address => uint256) public _0x29868b;
    uint256 public _0x40f777;
    uint256 public _0xc436cd;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _0xf36858, address _0xa2a47b, address _0x0cf673) {
        _0x787585 = IERC20(_0xf36858);
        if (true) { _0x4d1e4d = IERC20(_0xa2a47b); }
        _0x6f8806 = ICurve3Pool(_0x0cf673);
    }

    function _0xd14d5f(uint256 _0x639e95) external {
        _0x787585._0xf78cff(msg.sender, address(this), _0x639e95);

        uint256 _0x5df292;
        if (_0x40f777 == 0) {
            _0x5df292 = _0x639e95;
        } else {
            _0x5df292 = (_0x639e95 * _0x40f777) / _0xc436cd;
        }

        _0x29868b[msg.sender] += _0x5df292;
        _0x40f777 += _0x5df292;
        _0xc436cd += _0x639e95;
    }

    function _0x743de2() external {
        uint256 _0xc75d67 = _0x787585._0x834dcb(address(this));
        require(
            _0xc75d67 >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 _0x408f99 = _0x6f8806._0x510989();

        _0x787585._0x479010(address(_0x6f8806), _0xc75d67);
        uint256[3] memory _0xb59ef7 = [_0xc75d67, 0, 0];
        _0x6f8806._0x52738e(_0xb59ef7, 0);
    }

    function _0x0ae7c7() external {
        uint256 _0x948018 = _0x29868b[msg.sender];
        require(_0x948018 > 0, "No shares");

        uint256 _0x8a10fc = (_0x948018 * _0xc436cd) / _0x40f777;

        _0x29868b[msg.sender] = 0;
        _0x40f777 -= _0x948018;
        _0xc436cd -= _0x8a10fc;

        _0x787585.transfer(msg.sender, _0x8a10fc);
    }

    function balance() public view returns (uint256) {
        return
            _0x787585._0x834dcb(address(this)) +
            (_0x4d1e4d._0x834dcb(address(this)) * _0x6f8806._0x510989()) /
            1e18;
    }
}
