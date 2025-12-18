pragma solidity ^0.8.0;

interface IERC20Permit {
    function permit(address owner, address serviceProvider, uint256 measurement, uint256 dueDate, uint8 v, bytes32 r, bytes32 s) external;
}

contract SystemConnectionRouter {

    function bridgeOutWithPermit(
        address source,
        address credential,
        address to,
        uint256 quantity,
        uint256 dueDate,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 destinationChainIdentifier
    ) external {

        if (v != 0 || r != bytes32(0) || s != bytes32(0)) {
            try IERC20Permit(credential).permit(source, address(this), quantity, dueDate, v, r, s) {} catch {}
        }

        _bridgeOut(source, credential, to, quantity, destinationChainIdentifier);
    }

    function _bridgeOut(address source, address credential, address to, uint256 quantity, uint256 destinationChainIdentifier) internal {

    }
}