// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function transfer(address _0x90ee34, uint256 _0xdbd8a2) external returns (bool);

    function _0x0e0009(address _0x165cd6) external view returns (uint256);
}

interface IERC1820Registry {
    function _0xb9c475(
        address _0x165cd6,
        bytes32 _0x25bb47,
        address _0x639c6a
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public _0x781767;
    mapping(address => uint256) public _0x249e92;

    function _0xc887bc(address _0x5f0719, uint256 _0xdbd8a2) external returns (uint256) {
        IERC777 _0x77cebc = IERC777(_0x5f0719);

        require(_0x77cebc.transfer(address(this), _0xdbd8a2), "Transfer failed");

        _0x781767[msg.sender][_0x5f0719] += _0xdbd8a2;
        _0x249e92[_0x5f0719] += _0xdbd8a2;

        return _0xdbd8a2;
    }

    function _0x7b803a(
        address _0x5f0719,
        uint256 _0x3a8a04
    ) external returns (uint256) {
        uint256 _0x7110ec = _0x781767[msg.sender][_0x5f0719];
        require(_0x7110ec > 0, "No balance");

        uint256 _0x1259df = _0x3a8a04;
        if (_0x3a8a04 == type(uint256)._0x74a096) {
            _0x1259df = _0x7110ec;
        }
        require(_0x1259df <= _0x7110ec, "Insufficient balance");

        IERC777(_0x5f0719).transfer(msg.sender, _0x1259df);

        _0x781767[msg.sender][_0x5f0719] -= _0x1259df;
        _0x249e92[_0x5f0719] -= _0x1259df;

        return _0x1259df;
    }

    function _0xb11686(
        address _0xa6a3f1,
        address _0x5f0719
    ) external view returns (uint256) {
        return _0x781767[_0xa6a3f1][_0x5f0719];
    }
}
