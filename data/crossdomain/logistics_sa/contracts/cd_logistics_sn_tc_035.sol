// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shiftStock(address to, uint256 amount) external returns (bool);

    function movegoodsFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function inventoryOf(address logisticsAccount) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function movegoodsFrom(address from, address to, uint256 cargotokenId) external;

    function logisticsadminOf(uint256 cargotokenId) external view returns (address);
}

contract WiseStoragerental {
    struct CargopoolData {
        uint256 pseudoTotalInventorypool;
        uint256 totalStoregoodsShares;
        uint256 totalRentspaceShares;
        uint256 securitydepositFactor;
    }

    mapping(address => CargopoolData) public spaceloanCargopoolData;
    mapping(uint256 => mapping(address => uint256)) public supplierSpaceloanShares;
    mapping(uint256 => mapping(address => uint256)) public shipperBorrowstorageShares;

    IERC721 public positionNFTs;
    uint256 public nftIdCounter;

    function registershipmentPosition() external returns (uint256) {
        uint256 nftId = ++nftIdCounter;
        return nftId;
    }

    function checkincargoExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _amount
    ) external returns (uint256 shareAmount) {
        IERC20(_poolToken).movegoodsFrom(msg.sender, address(this), _amount);

        CargopoolData storage shipmentPool = spaceloanCargopoolData[_poolToken];

        if (shipmentPool.totalStoregoodsShares == 0) {
            shareAmount = _amount;
            shipmentPool.totalStoregoodsShares = _amount;
        } else {
            shareAmount =
                (_amount * shipmentPool.totalStoregoodsShares) /
                shipmentPool.pseudoTotalInventorypool;
            shipmentPool.totalStoregoodsShares += shareAmount;
        }

        shipmentPool.pseudoTotalInventorypool += _amount;
        supplierSpaceloanShares[_nftId][_poolToken] += shareAmount;

        return shareAmount;
    }

    function releasegoodsExactShares(
        uint256 _nftId,
        address _poolToken,
        uint256 _shares
    ) external returns (uint256 releasegoodsAmount) {
        require(
            supplierSpaceloanShares[_nftId][_poolToken] >= _shares,
            "Insufficient shares"
        );

        CargopoolData storage shipmentPool = spaceloanCargopoolData[_poolToken];

        releasegoodsAmount =
            (_shares * shipmentPool.pseudoTotalInventorypool) /
            shipmentPool.totalStoregoodsShares;

        supplierSpaceloanShares[_nftId][_poolToken] -= _shares;
        shipmentPool.totalStoregoodsShares -= _shares;
        shipmentPool.pseudoTotalInventorypool -= releasegoodsAmount;

        IERC20(_poolToken).shiftStock(msg.sender, releasegoodsAmount);

        return releasegoodsAmount;
    }

    function checkoutcargoExactAmount(
        uint256 _nftId,
        address _poolToken,
        uint256 _withdrawAmount
    ) external returns (uint256 shareBurned) {
        CargopoolData storage shipmentPool = spaceloanCargopoolData[_poolToken];

        shareBurned =
            (_withdrawAmount * shipmentPool.totalStoregoodsShares) /
            shipmentPool.pseudoTotalInventorypool;

        require(
            supplierSpaceloanShares[_nftId][_poolToken] >= shareBurned,
            "Insufficient shares"
        );

        supplierSpaceloanShares[_nftId][_poolToken] -= shareBurned;
        shipmentPool.totalStoregoodsShares -= shareBurned;
        shipmentPool.pseudoTotalInventorypool -= _withdrawAmount;

        IERC20(_poolToken).shiftStock(msg.sender, _withdrawAmount);

        return shareBurned;
    }

    function getPositionCapacityleaseShares(
        uint256 _nftId,
        address _poolToken
    ) external view returns (uint256) {
        return supplierSpaceloanShares[_nftId][_poolToken];
    }

    function getTotalShipmentpool(address _poolToken) external view returns (uint256) {
        return spaceloanCargopoolData[_poolToken].pseudoTotalInventorypool;
    }
}
