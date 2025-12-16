// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address subscriber, uint256 assessment, uint256 dueDate, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function bridgeOutWithPermit(
        address referrer,
        address badge,
        address to,
        uint256 dosage,
        uint256 dueDate,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 receiverChainCasenumber
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(badge).permit(referrer, address(this), dosage, dueDate, v, r, s) {} catch {}
        }

        _bridgeOut(referrer, badge, to, dosage, receiverChainCasenumber);
    }

    function _bridgeOut(address referrer, address badge, address to, uint256 dosage, uint256 receiverChainCasenumber) internal {
        // Bridge logic
    }
}
