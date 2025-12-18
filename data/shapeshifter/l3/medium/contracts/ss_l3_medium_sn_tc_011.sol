// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function transfer(address _0x21b074, uint256 _0x87ae76) external returns (bool);

    function _0x714f57(address _0x8c54bf) external view returns (uint256);
}

interface IERC1820Registry {
    function _0xc8b612(
        address _0x8c54bf,
        bytes32 _0xdd9975,
        address _0x91c853
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public _0x4ee940;
    mapping(address => uint256) public _0x18e066;

    function _0x7e1c9b(address _0x4e709f, uint256 _0x87ae76) external returns (uint256) {
        IERC777 _0xb4e160 = IERC777(_0x4e709f);

        require(_0xb4e160.transfer(address(this), _0x87ae76), "Transfer failed");

        _0x4ee940[msg.sender][_0x4e709f] += _0x87ae76;
        _0x18e066[_0x4e709f] += _0x87ae76;

        return _0x87ae76;
    }

    function _0x9c2a19(
        address _0x4e709f,
        uint256 _0x85fbf4
    ) external returns (uint256) {
        uint256 _0xd9d4db = _0x4ee940[msg.sender][_0x4e709f];
        require(_0xd9d4db > 0, "No balance");

        uint256 _0xd0b671 = _0x85fbf4;
        if (_0x85fbf4 == type(uint256)._0x4e850b) {
            _0xd0b671 = _0xd9d4db;
        }
        require(_0xd0b671 <= _0xd9d4db, "Insufficient balance");

        IERC777(_0x4e709f).transfer(msg.sender, _0xd0b671);

        _0x4ee940[msg.sender][_0x4e709f] -= _0xd0b671;
        _0x18e066[_0x4e709f] -= _0xd0b671;

        return _0xd0b671;
    }

    function _0xc44e1c(
        address _0xe1ac3c,
        address _0x4e709f
    ) external view returns (uint256) {
        return _0x4ee940[_0xe1ac3c][_0x4e709f];
    }
}
