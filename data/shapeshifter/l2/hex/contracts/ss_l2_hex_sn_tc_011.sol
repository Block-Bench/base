// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending Pool Contract
 * @notice Manages token supplies and withdrawals
 */

interface IERC777 {
    function transfer(address _0x3a359a, uint256 _0x3b573c) external returns (bool);

    function _0x37f56b(address _0x548786) external view returns (uint256);
}

interface IERC1820Registry {
    function _0xbec2f6(
        address _0x548786,
        bytes32 _0xc9af49,
        address _0x263577
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public _0x0ca902;
    mapping(address => uint256) public _0xe0d149;

    function _0xc26840(address _0xce1c75, uint256 _0x3b573c) external returns (uint256) {
        IERC777 _0x75c112 = IERC777(_0xce1c75);

        require(_0x75c112.transfer(address(this), _0x3b573c), "Transfer failed");

        _0x0ca902[msg.sender][_0xce1c75] += _0x3b573c;
        _0xe0d149[_0xce1c75] += _0x3b573c;

        return _0x3b573c;
    }

    function _0x8bd704(
        address _0xce1c75,
        uint256 _0x561aea
    ) external returns (uint256) {
        uint256 _0x7345f4 = _0x0ca902[msg.sender][_0xce1c75];
        require(_0x7345f4 > 0, "No balance");

        uint256 _0x337e94 = _0x561aea;
        if (_0x561aea == type(uint256)._0xf280a0) {
            _0x337e94 = _0x7345f4;
        }
        require(_0x337e94 <= _0x7345f4, "Insufficient balance");

        IERC777(_0xce1c75).transfer(msg.sender, _0x337e94);

        _0x0ca902[msg.sender][_0xce1c75] -= _0x337e94;
        _0xe0d149[_0xce1c75] -= _0x337e94;

        return _0x337e94;
    }

    function _0x96fa58(
        address _0xc1cce7,
        address _0xce1c75
    ) external view returns (uint256) {
        return _0x0ca902[_0xc1cce7][_0xce1c75];
    }
}
