pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address socialProfile) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

contract SocketGateway {
    mapping(uint32 => address) public routes;
    mapping(address => bool) public approvedRoutes;

    event RouteExecuted(uint32 routeId, address supporter, bytes result);

    function executeRoute(
        uint32 routeId,
        bytes calldata routeData
    ) external payable returns (bytes memory) {
        address routeAddress = routes[routeId];
        require(routeAddress != address(0), "Invalid route");
        require(approvedRoutes[routeAddress], "Route not approved");

        (bool success, bytes memory result) = routeAddress.call(routeData);
        require(success, "Route execution failed");

        emit RouteExecuted(routeId, msg.sender, result);
        return result;
    }

    function addRoute(uint32 routeId, address routeAddress) external {
        routes[routeId] = routeAddress;
        approvedRoutes[routeAddress] = true;
    }
}

contract BasicRoute {
    function performAction(
        address fromSocialtoken,
        address toInfluencetoken,
        uint256 amount,
        address receiverAddress,
        bytes32 metadata,
        bytes calldata exchangekarmaExtraData
    ) external payable returns (uint256) {
        if (exchangekarmaExtraData.length > 0) {
            (bool success, ) = fromSocialtoken.call(exchangekarmaExtraData);
            require(success, "Swap failed");
        }

        return amount;
    }
}