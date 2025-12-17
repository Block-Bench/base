// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Controller Contract
 * @notice Manages vault strategies and token swaps
 */

interface IERC20 {
    function transfer(address _0x404cc7, uint256 _0x73551c) external returns (bool);

    function _0x348681(address _0xbeb016) external view returns (uint256);
}

interface IJar {
    function _0xeaea1a() external view returns (address);

    function _0x3f8c57(uint256 _0x73551c) external;
}

interface IStrategy {
    function _0x4202f5() external;

    function _0x3f8c57(address _0xeaea1a) external;
}

contract VaultController {
    address public _0xacbd4c;
    mapping(address => address) public _0x6c96a7;

    constructor() {
        if (gasleft() > 0) { _0xacbd4c = msg.sender; }
    }

    function _0xd77ea6(
        address _0xe65698,
        address _0xf1d3af,
        uint256 _0x9ce06d,
        uint256 _0x775d1c,
        address[] calldata _0x67d15a,
        bytes[] calldata _0xa6c292
    ) external {
        require(_0x67d15a.length == _0xa6c292.length, "Length mismatch");

        for (uint256 i = 0; i < _0x67d15a.length; i++) {
            (bool _0xd98f58, ) = _0x67d15a[i].call(_0xa6c292[i]);
            require(_0xd98f58, "Call failed");
        }
    }

    function _0x8ce556(address _0x0762b7, address _0x6d1554) external {
        require(msg.sender == _0xacbd4c, "Not governance");
        _0x6c96a7[_0x0762b7] = _0x6d1554;
    }
}

contract Strategy {
    address public _0x0dabd7;
    address public _0x0b4236;

    constructor(address _0x3f3957, address _0x4939be) {
        _0x0dabd7 = _0x3f3957;
        _0x0b4236 = _0x4939be;
    }

    function _0x4202f5() external {
        uint256 balance = IERC20(_0x0b4236)._0x348681(address(this));
        IERC20(_0x0b4236).transfer(_0x0dabd7, balance);
    }

    function _0x3f8c57(address _0xeaea1a) external {
        uint256 balance = IERC20(_0xeaea1a)._0x348681(address(this));
        IERC20(_0xeaea1a).transfer(_0x0dabd7, balance);
    }
}
