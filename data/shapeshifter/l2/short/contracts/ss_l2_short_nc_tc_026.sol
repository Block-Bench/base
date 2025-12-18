pragma solidity ^0.8.0;

interface IERC20Permit {
    function g(address i, address e, uint256 value, uint256 d, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function a(
        address from,
        address h,
        address j,
        uint256 f,
        uint256 d,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 c
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(h).g(from, address(this), f, d, v, r, s) {} catch {}
        }

        b(from, h, j, f, c);
    }

    function b(address from, address h, address j, uint256 f, uint256 c) internal {

    }
}