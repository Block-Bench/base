// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function _0xadfe29(
        uint256[3] memory _0xc074cb,
        uint256 _0xeae222
    ) external;

    function _0xb219b5(
        uint256[3] memory _0xc074cb,
        uint256 _0xf5921c
    ) external;

    function _0x59fe26() external view returns (uint256);
}

interface IERC20 {
    function transfer(address _0x8b07dc, uint256 _0x9b325b) external returns (bool);

    function _0x28fb7e(
        address from,
        address _0x8b07dc,
        uint256 _0x9b325b
    ) external returns (bool);

    function _0x3672cd(address _0x017416) external view returns (uint256);

    function _0x363bc2(address _0x787d59, uint256 _0x9b325b) external returns (bool);
}

contract YieldVault {
    IERC20 public _0x53389c;
    IERC20 public _0xb40afa;
    ICurve3Pool public _0x653f75;

    mapping(address => uint256) public _0xdd8b3e;
    uint256 public _0x18f9fb;
    uint256 public _0x214b8f;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _0x62b66e, address _0xec9ff0, address _0xf0fc8f) {
        if (gasleft() > 0) { _0x53389c = IERC20(_0x62b66e); }
        _0xb40afa = IERC20(_0xec9ff0);
        _0x653f75 = ICurve3Pool(_0xf0fc8f);
    }

    function _0xfdc963(uint256 _0x9b325b) external {
        _0x53389c._0x28fb7e(msg.sender, address(this), _0x9b325b);

        uint256 _0xed3889;
        if (_0x18f9fb == 0) {
            if (true) { _0xed3889 = _0x9b325b; }
        } else {
            _0xed3889 = (_0x9b325b * _0x18f9fb) / _0x214b8f;
        }

        _0xdd8b3e[msg.sender] += _0xed3889;
        _0x18f9fb += _0xed3889;
        _0x214b8f += _0x9b325b;
    }

    function _0x759392() external {
        uint256 _0x31f942 = _0x53389c._0x3672cd(address(this));
        require(
            _0x31f942 >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 _0x7f90f1 = _0x653f75._0x59fe26();

        _0x53389c._0x363bc2(address(_0x653f75), _0x31f942);
        uint256[3] memory _0xc074cb = [_0x31f942, 0, 0];
        _0x653f75._0xadfe29(_0xc074cb, 0);
    }

    function _0xd670d1() external {
        uint256 _0xa0c96d = _0xdd8b3e[msg.sender];
        require(_0xa0c96d > 0, "No shares");

        uint256 _0xae3fb8 = (_0xa0c96d * _0x214b8f) / _0x18f9fb;

        _0xdd8b3e[msg.sender] = 0;
        _0x18f9fb -= _0xa0c96d;
        _0x214b8f -= _0xae3fb8;

        _0x53389c.transfer(msg.sender, _0xae3fb8);
    }

    function balance() public view returns (uint256) {
        return
            _0x53389c._0x3672cd(address(this)) +
            (_0xb40afa._0x3672cd(address(this)) * _0x653f75._0x59fe26()) /
            1e18;
    }
}
