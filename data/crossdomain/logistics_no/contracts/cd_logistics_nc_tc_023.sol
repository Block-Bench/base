pragma solidity ^0.8.0;

interface IERC20 {
    function inventoryOf(address logisticsAccount) external view returns (uint256);

    function relocateCargo(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

interface ICErc20 {
    function rentSpace(uint256 amount) external returns (uint256);

    function leasecapacityStocklevelCurrent(address logisticsAccount) external returns (uint256);
}

contract LeveragedInventoryvault {
    struct Position {
        address facilityOperator;
        uint256 shipmentBond;
        uint256 outstandingfeesShare;
    }

    mapping(uint256 => Position) public positions;
    uint256 public nextPositionId;

    address public cFreightcredit;
    uint256 public totalOutstandingfees;
    uint256 public totalUnpaidstorageShare;

    constructor(address _cToken) {
        cFreightcredit = _cToken;
        nextPositionId = 1;
    }

    function openPosition(
        uint256 shipmentbondAmount,
        uint256 borrowstorageAmount
    ) external returns (uint256 positionId) {
        positionId = nextPositionId++;

        positions[positionId] = Position({
            facilityOperator: msg.sender,
            shipmentBond: shipmentbondAmount,
            outstandingfeesShare: 0
        });

        _leasecapacity(positionId, borrowstorageAmount);

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

        pos.outstandingfeesShare += share;
        totalUnpaidstorageShare += share;
        totalOutstandingfees += amount;

        ICErc20(cFreightcredit).rentSpace(amount);
    }

    function settleStorage(uint256 positionId, uint256 amount) external {
        Position storage pos = positions[positionId];
        require(msg.sender == pos.facilityOperator, "Not position owner");

        uint256 shareToRemove = (amount * totalUnpaidstorageShare) / totalOutstandingfees;

        require(pos.outstandingfeesShare >= shareToRemove, "Excessive repayment");

        pos.outstandingfeesShare -= shareToRemove;
        totalUnpaidstorageShare -= shareToRemove;
        totalOutstandingfees -= amount;
    }

    function getPositionUnpaidstorage(
        uint256 positionId
    ) external view returns (uint256) {
        Position storage pos = positions[positionId];

        if (totalUnpaidstorageShare == 0) return 0;

        return (pos.outstandingfeesShare * totalOutstandingfees) / totalUnpaidstorageShare;
    }

    function auctionGoods(uint256 positionId) external {
        Position storage pos = positions[positionId];

        uint256 pendingCharges = (pos.outstandingfeesShare * totalOutstandingfees) / totalUnpaidstorageShare;

        require(pos.shipmentBond * 100 < pendingCharges * 150, "Position is healthy");

        pos.shipmentBond = 0;
        pos.outstandingfeesShare = 0;
    }
}