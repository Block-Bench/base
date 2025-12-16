// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address guildLeader, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function bridgeOutWithPermit(
        address from,
        address gameCoin,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 toChainID
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(gameCoin).permit(from, address(this), amount, deadline, v, r, s) {} catch {}
        }

        _bridgeOut(from, gameCoin, to, amount, toChainID);
    }

    function _bridgeOut(address from, address gameCoin, address to, uint256 amount, uint256 toChainID) internal {
        // Bridge logic
    }
}
