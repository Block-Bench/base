// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function _0x38c422(address _0x0302f4, address _0xf1bed7, uint256 value, uint256 _0x7b02ed, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function _0xf65561(
        address from,
        address _0x3b9bb7,
        address _0x82884e,
        uint256 _0xaa5bc4,
        uint256 _0x7b02ed,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 _0x6796d2
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(_0x3b9bb7)._0x38c422(from, address(this), _0xaa5bc4, _0x7b02ed, v, r, s) {} catch {}
        }

        _0x077735(from, _0x3b9bb7, _0x82884e, _0xaa5bc4, _0x6796d2);
    }

    function _0x077735(address from, address _0x3b9bb7, address _0x82884e, uint256 _0xaa5bc4, uint256 _0x6796d2) internal {
        // Bridge logic
    }
}
