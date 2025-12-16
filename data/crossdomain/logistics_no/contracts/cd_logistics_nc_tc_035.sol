pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function inventoryOf(address logisticsAccount) external view returns (uint256);

    function clearCargo(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function shiftstockFrom(address from, address to, uint256 cargotokenId) external;

    function logisticsadminOf(uint256 cargotokenId) external view returns (address);
}

contract WiseCapacitylease {
    struct ShipmentpoolData {
        uint256 pseudoTotalCargopool;
        uint256 totalStoregoodsShares;
        uint256 totalLeasecapacityShares;
        uint256 insurancebondFactor;
    }

    mapping(address => ShipmentpoolData) public spaceloanShipmentpoolData;
    mapping(uint256 => mapping(address => uint256)) public merchantStoragerentalShares;
    mapping(uint256 => mapping(address => uint256)) public consigneeBorrowstorageShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function recordcargoPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function storegoodsExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).shiftstockFrom(msg.sender, address(this), _amount);

        ShipmentpoolData storage freightPool = spaceloanShipmentpoolData[_poolToken];

        if (freightPool.totalStoregoodsShares == 0) {
            shareAmount = _amount;
            freightPool.totalStoregoodsShares = _amount;
        } else {
            shareAmount =
                (_amount * freightPool.totalStoregoodsShares) /
                freightPool.pseudoTotalCargopool;
            freightPool.totalStoregoodsShares += shareAmount;
        }

        freightPool.pseudoTotalCargopool += _amount;
        merchantStoragerentalShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function delivergoodsExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 delivergoodsAmount) {
        require(
            merchantStoragerentalShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        ShipmentpoolData storage freightPool = spaceloanShipmentpoolData[_poolToken];

        delivergoodsAmount =
            (_shares * freightPool.pseudoTotalCargopool) /
            freightPool.totalStoregoodsShares;

        merchantStoragerentalShares[_nftId][_poolToken] -= _shares;
        freightPool.totalStoregoodsShares -= _shares;
        freightPool.pseudoTotalCargopool -= delivergoodsAmount;

        IERC20(_poolToken).shiftStock(msg.sender, delivergoodsAmount);

        return delivergoodsAmount;
    }

    function shipitemsExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        ShipmentpoolData storage freightPool = spaceloanShipmentpoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * freightPool.totalStoregoodsShares) /
            freightPool.pseudoTotalCargopool;

        require(
            merchantStoragerentalShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        merchantStoragerentalShares[_nftId][_poolToken] -= shareBurned;
        freightPool.totalStoregoodsShares -= shareBurned;
        freightPool.pseudoTotalCargopool -= _withdrawAmount;

        IERC20(_poolToken).shiftStock(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionCapacityleaseShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return merchantStoragerentalShares[_nftId][_poolToken];
    }

    function getTotalFreightpool(address _poolToken) external view returns (uint256) {
        return spaceloanShipmentpoolData[_poolToken].pseudoTotalCargopool;
    }
}