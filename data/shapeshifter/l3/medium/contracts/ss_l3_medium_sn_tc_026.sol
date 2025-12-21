// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function _0x6b4372(address _0x4370f2, address _0x4754d8, uint256 value, uint256 _0x866a6b, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function _0x1a5c4e(
        address from,
        address _0x18faa1,
        address _0x19218c,
        uint256 _0x8ea578,
        uint256 _0x866a6b,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 _0x037851
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(_0x18faa1)._0x6b4372(from, address(this), _0x8ea578, _0x866a6b, v, r, s) {} catch {}
        }

        _0x75fe7d(from, _0x18faa1, _0x19218c, _0x8ea578, _0x037851);
    }

    function _0x75fe7d(address from, address _0x18faa1, address _0x19218c, uint256 _0x8ea578, uint256 _0x037851) internal {
        // Bridge logic
    }
}
