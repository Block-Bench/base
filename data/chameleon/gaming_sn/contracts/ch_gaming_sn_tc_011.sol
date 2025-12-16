// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Lending BountyPool Contract
 * @notice Manages gem supplies and withdrawals
 */

interface IERC777 {
    function transfer(address to, uint256 count) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IERC1820Registry {
    function collectionPortalImplementer(
        address profile,
        bytes32 portalSignature,
        address implementer
    ) external;
}

contract LendingPool {
    mapping(address => mapping(address => uint256)) public supplied;
    mapping(address => uint256) public aggregateSupplied;

    function contributeAssets(address asset, uint256 count) external returns (uint256) {
        IERC777 gem = IERC777(asset);

        require(gem.transfer(address(this), count), "Transfer failed");

        supplied[msg.sender][asset] += count;
        aggregateSupplied[asset] += count;

        return count;
    }

    function harvestGold(
        address asset,
        uint256 requestedMeasure
    ) external returns (uint256) {
        uint256 adventurerGoldholding = supplied[msg.sender][asset];
        require(adventurerGoldholding > 0, "No balance");

        uint256 gathertreasureSum = requestedMeasure;
        if (requestedMeasure == type(uint256).ceiling) {
            gathertreasureSum = adventurerGoldholding;
        }
        require(gathertreasureSum <= adventurerGoldholding, "Insufficient balance");

        IERC777(asset).transfer(msg.sender, gathertreasureSum);

        supplied[msg.sender][asset] -= gathertreasureSum;
        aggregateSupplied[asset] -= gathertreasureSum;

        return gathertreasureSum;
    }

    function retrieveSupplied(
        address character,
        address asset
    ) external view returns (uint256) {
        return supplied[character][asset];
    }
}
