pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address user, uint256 price, uint256 timeLimit, uint8 v, bytes32 r, bytes32 s) external;
}

contract BridgeRouter {

    function bridgeOutWithPermit(
        address source,
        address gem,
        address to,
        uint256 quantity,
        uint256 timeLimit,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 targetChainTag
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(gem).permit(source, address(this), quantity, timeLimit, v, r, s) {} catch {}
        }

        _bridgeOut(source, gem, to, quantity, targetChainTag);
    }

    function _bridgeOut(address source, address gem, address to, uint256 quantity, uint256 targetChainTag) internal {

    }
}