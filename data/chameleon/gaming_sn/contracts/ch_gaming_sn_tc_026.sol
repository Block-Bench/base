// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address consumer, uint256 cost, uint256 cutoffTime, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function bridgeOutWithPermit(
        address origin,
        address gem,
        address to,
        uint256 quantity,
        uint256 cutoffTime,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 destinationChainIdentifier
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(gem).permit(origin, address(this), quantity, cutoffTime, v, r, s) {} catch {}
        }

        _bridgeOut(origin, gem, to, quantity, destinationChainIdentifier);
    }

    function _bridgeOut(address origin, address gem, address to, uint256 quantity, uint256 destinationChainIdentifier) internal {
        // Bridge logic
    }
}
