pragma solidity ^0.8.0;

interface IERC20Permit {
    function f(address i, address e, uint256 value, uint256 d, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function a(
        address from,
        address h,
        address j,
        uint256 g,
        uint256 d,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 c
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(h).f(from, address(this), g, d, v, r, s) {} catch {}
        }

        b(from, h, j, g, c);
    }

    function b(address from, address h, address j, uint256 g, uint256 c) internal {

    }
}