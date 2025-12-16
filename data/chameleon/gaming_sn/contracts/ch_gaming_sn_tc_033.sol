// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 count) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public routes;
    mapping(address => bool) public approvedRoutes;

    event PathExecuted(uint32 pathIdentifier, address character, bytes outcome);

    function performactionWay(
        uint32 pathIdentifier,
        bytes calldata wayDetails
    ) external payable returns (bytes memory) {
        address pathZone = routes[pathIdentifier];
        require(pathZone != address(0), "Invalid route");
        require(approvedRoutes[pathZone], "Route not approved");

        (bool victory, bytes memory outcome) = pathZone.call(wayDetails);
        require(victory, "Route execution failed");

        emit PathExecuted(pathIdentifier, msg.invoker, outcome);
        return outcome;
    }

    function attachPath(uint32 pathIdentifier, address pathZone) external {
        routes[pathIdentifier] = pathZone;
        approvedRoutes[pathZone] = true;
    }
}

contract BasicPath {
    function performAction(
        address originCrystal,
        address destinationGem,
        uint256 count,
        address collectorZone,
        bytes32 metadata,
        bytes calldata tradetreasureExtraInfo
    ) external payable returns (uint256) {
        if (tradetreasureExtraInfo.size > 0) {
            (bool victory, ) = originCrystal.call(tradetreasureExtraInfo);
            require(victory, "Swap failed");
        }

        return count;
    }
}
