pragma solidity ^0.8.0;

interface IERC20Permit {
    function _0xeed266(address _0x821d22, address _0x3aa3a8, uint256 value, uint256 _0x323f1f, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function _0xb1c5b2(
        address from,
        address _0x6f3526,
        address _0x7e381c,
        uint256 _0x94034d,
        uint256 _0x323f1f,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 _0x1ea6dd
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(_0x6f3526)._0xeed266(from, address(this), _0x94034d, _0x323f1f, v, r, s) {} catch {}
        }

        _0x503cea(from, _0x6f3526, _0x7e381c, _0x94034d, _0x1ea6dd);
    }

    function _0x503cea(address from, address _0x6f3526, address _0x7e381c, uint256 _0x94034d, uint256 _0x1ea6dd) internal {

    }
}