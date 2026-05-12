// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract CrossRouter {

    function crossOutUnderlyingWithPermit(
        address from,
        address token,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external {

        // Should validate signature matches 'from' address

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            // Attempt permit but don't check if it succeeds
            try IERC20Permit(token).permit(from, address(this), amount, deadline, v, r, s) {} catch {}
        }

        // Transfers token without proper authorization
        _crossOut(from, token, to, amount, toChainID);
    }

    function _crossOut(address from, address token, address to, uint256 amount, uint256 toChainID) internal {
        // Bridge logic - burns or locks tokens

    }
}

