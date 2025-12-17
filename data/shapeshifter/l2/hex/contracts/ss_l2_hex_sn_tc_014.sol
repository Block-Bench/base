// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function _0x37e09d(
        uint256[3] memory _0xc82929,
        uint256 _0x19cb60
    ) external;

    function _0x99ccf7(
        uint256[3] memory _0xc82929,
        uint256 _0x8ca107
    ) external;

    function _0x9f5fb3() external view returns (uint256);
}

interface IERC20 {
    function transfer(address _0xaf8f10, uint256 _0x2c4619) external returns (bool);

    function _0x23d958(
        address from,
        address _0xaf8f10,
        uint256 _0x2c4619
    ) external returns (bool);

    function _0xecc4a9(address _0x352b09) external view returns (uint256);

    function _0x2562da(address _0x197248, uint256 _0x2c4619) external returns (bool);
}

contract YieldVault {
    IERC20 public _0xaeab52;
    IERC20 public _0xf4eb14;
    ICurve3Pool public _0xbe436a;

    mapping(address => uint256) public _0x1fb273;
    uint256 public _0x3e4f68;
    uint256 public _0x42432c;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _0xd0cf73, address _0x6ecbbb, address _0xb5d0e3) {
        _0xaeab52 = IERC20(_0xd0cf73);
        _0xf4eb14 = IERC20(_0x6ecbbb);
        _0xbe436a = ICurve3Pool(_0xb5d0e3);
    }

    function _0xd40a0e(uint256 _0x2c4619) external {
        _0xaeab52._0x23d958(msg.sender, address(this), _0x2c4619);

        uint256 _0xd0e658;
        if (_0x3e4f68 == 0) {
            _0xd0e658 = _0x2c4619;
        } else {
            _0xd0e658 = (_0x2c4619 * _0x3e4f68) / _0x42432c;
        }

        _0x1fb273[msg.sender] += _0xd0e658;
        _0x3e4f68 += _0xd0e658;
        _0x42432c += _0x2c4619;
    }

    function _0x0a7b1b() external {
        uint256 _0x1b1c0e = _0xaeab52._0xecc4a9(address(this));
        require(
            _0x1b1c0e >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 _0xfcf95d = _0xbe436a._0x9f5fb3();

        _0xaeab52._0x2562da(address(_0xbe436a), _0x1b1c0e);
        uint256[3] memory _0xc82929 = [_0x1b1c0e, 0, 0];
        _0xbe436a._0x37e09d(_0xc82929, 0);
    }

    function _0x87582e() external {
        uint256 _0x7f8e58 = _0x1fb273[msg.sender];
        require(_0x7f8e58 > 0, "No shares");

        uint256 _0xbd7927 = (_0x7f8e58 * _0x42432c) / _0x3e4f68;

        _0x1fb273[msg.sender] = 0;
        _0x3e4f68 -= _0x7f8e58;
        _0x42432c -= _0xbd7927;

        _0xaeab52.transfer(msg.sender, _0xbd7927);
    }

    function balance() public view returns (uint256) {
        return
            _0xaeab52._0xecc4a9(address(this)) +
            (_0xf4eb14._0xecc4a9(address(this)) * _0xbe436a._0x9f5fb3()) /
            1e18;
    }
}
