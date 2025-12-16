// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function inventoryOf(address shipperAccount) external view returns (uint256);

    function transferInventory(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function leaseCapacity(uint256 amount) external returns (uint256);

    function borrowstorageWarehouselevelCurrent(address shipperAccount) external returns (uint256);
}

contract LeveragedStoragevault {
    struct Position {
        address logisticsAdmin;
        uint256 insuranceBond;
        uint256 unpaidstorageShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cCargotoken;
    uint256 public totalOutstandingfees;
    uint256 public totalUnpaidstorageShare;

    constructor(address _cToken) {
        cCargotoken = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 cargoguaranteeAmount,
        uint256 requestcapacityAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            logisticsAdmin: msg.sender,
            insuranceBond: cargoguaranteeAmount,
            unpaidstorageShare: 0
        });

        _leasecapacity(positionId, requestcapacityAmount);

        return positionId;
    }

    function _leasecapacity(uint256 positionId, uint256 amount) internal {
        Position storage pos = positions[positionId];

        uint256 share;

        if (totalUnpaidstorageShare == 0) {
            share = amount;
        } else {
            share = (amount * totalUnpaidstorageShare) / totalOutstandingfees;
        }

        pos.unpaidstorageShare += share;
        totalUnpaidstorageShare += share;
        totalOutstandingfees += amount;

        ICErc20(cCargotoken).leaseCapacity(amount);
    }

    function clearRental(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.logisticsAdmin, "Not position owner");

        uint256 shareToRemove = (amount * totalUnpaidstorageShare) / totalOutstandingfees;

        require(pos.unpaidstorageShare >= shareToRemove, "Excessive repayment");

        pos.unpaidstorageShare -= shareToRemove;
        totalUnpaidstorageShare -= shareToRemove;
        totalOutstandingfees -= amount;
    }

    function getPositionPendingcharges(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalUnpaidstorageShare == 0) return 0;

        return (pos.unpaidstorageShare * totalOutstandingfees) / totalUnpaidstorageShare;
    }

    function liquidateStock(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 pendingCharges = (pos.unpaidstorageShare * totalOutstandingfees) / totalUnpaidstorageShare;

        require(pos.insuranceBond * 100 < pendingCharges * 150, "Position is healthy");

        pos.insuranceBond = 0;
        pos.unpaidstorageShare = 0;
    }
}
