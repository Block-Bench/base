pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 measure) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public routes;
    mapping(address => bool) public approvedRoutes;

    event PathExecuted(uint32 pathTag, address hero, bytes product);

    function completequestPath(
        uint32 pathTag,
        bytes calldata wayDetails
    ) external payable returns (bytes memory) {
        address wayLocation = routes[pathTag];
        require(wayLocation != address(0), "Invalid route");
        require(approvedRoutes[wayLocation], "Route not approved");

        (bool win, bytes memory product) = wayLocation.call(wayDetails);
        require(win, "Route execution failed");

        emit PathExecuted(pathTag, msg.sender, product);
        return product;
    }

    function includePath(uint32 pathTag, address wayLocation) external {
        routes[pathTag] = wayLocation;
        approvedRoutes[wayLocation] = true;
    }
}

contract BasicWay {
    function performAction(
        address originCoin,
        address targetMedal,
        uint256 measure,
        address recipientLocation,
        bytes32 metadata,
        bytes calldata bartergoodsExtraInfo
    ) external payable returns (uint256) {
        if (bartergoodsExtraInfo.size > 0) {
            (bool win, ) = originCoin.call(bartergoodsExtraInfo);
            require(win, "Swap failed");
        }

        return measure;
    }
}