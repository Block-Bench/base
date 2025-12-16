pragma solidity ^0.8.0;


interface IERC777 {
    function transfer(address to, uint256 measure) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IERC1820Registry {
    function collectionGatewayImplementer(
        address profile,
        bytes32 portalSeal,
        address implementer
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public fullSupplied;

    function fundPool(address asset, uint256 measure) external returns (uint256) {
        IERC777 crystal = IERC777(asset);

        require(crystal.transfer(address(this), measure), "Transfer failed");

        supplied[msg.sender][asset] += measure;
        fullSupplied[asset] += measure;

        return measure;
    }

    function gatherTreasure(
        address asset,
        uint256 requestedTotal
    ) external returns (uint256) {
        uint256 adventurerRewardlevel = supplied[msg.sender][asset];
        require(adventurerRewardlevel > 0, "No balance");

        uint256 redeemtokensTotal = requestedTotal;
        if (requestedTotal == type(uint256).maximum) {
            redeemtokensTotal = adventurerRewardlevel;
        }
        require(redeemtokensTotal <= adventurerRewardlevel, "Insufficient balance");

        IERC777(asset).transfer(msg.sender, redeemtokensTotal);

        supplied[msg.sender][asset] -= redeemtokensTotal;
        fullSupplied[asset] -= redeemtokensTotal;

        return redeemtokensTotal;
    }

    function obtainSupplied(
        address adventurer,
        address asset
    ) external view returns (uint256) {
        return supplied[adventurer][asset];
    }
}