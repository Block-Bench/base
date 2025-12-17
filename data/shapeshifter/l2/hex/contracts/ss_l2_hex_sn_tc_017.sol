// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function transfer(address _0x64a2df, uint256 _0x3054d9) external returns (bool);

    function _0x23f64e(address _0xc98697) external view returns (uint256);
}

interface IJar {
    function _0x37a57f() external view returns (address);

    function _0x0a2371(uint256 _0x3054d9) external;
}

interface IStrategy {
    function _0x5d3217() external;

    function _0x0a2371(address _0x37a57f) external;
}

contract VaultController {
    address public _0x232b83;
    mapping(address => address) public _0x14c962;

    constructor() {
        _0x232b83 = msg.sender;
    }

    function _0x59772e(
        address _0xa944db,
        address _0xeb70d1,
        uint256 _0xc4b4ec,
        uint256 _0xfebec0,
        address[] calldata _0x65851d,
        bytes[] calldata _0xbed859
    ) external {
        require(_0x65851d.length == _0xbed859.length, "Length mismatch");

        for (uint256 i = 0; i < _0x65851d.length; i++) {
            (bool _0xe01e31, ) = _0x65851d[i].call(_0xbed859[i]);
            require(_0xe01e31, "Call failed");
        }
    }

    function _0x58e933(address _0x3baf41, address _0x1997e3) external {
        require(msg.sender == _0x232b83, "Not governance");
        _0x14c962[_0x3baf41] = _0x1997e3;
    }
}

contract Strategy {
    address public _0x13c40c;
    address public _0xa637e5;

    constructor(address _0xaa9e5c, address _0xac9194) {
        _0x13c40c = _0xaa9e5c;
        _0xa637e5 = _0xac9194;
    }

    function _0x5d3217() external {
        uint256 balance = IERC20(_0xa637e5)._0x23f64e(address(this));
        IERC20(_0xa637e5).transfer(_0x13c40c, balance);
    }

    function _0x0a2371(address _0x37a57f) external {
        uint256 balance = IERC20(_0x37a57f)._0x23f64e(address(this));
        IERC20(_0x37a57f).transfer(_0x13c40c, balance);
    }
}
