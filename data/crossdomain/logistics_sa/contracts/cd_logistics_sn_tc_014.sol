// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Cargopool {
    function add_openslots(
        uint256[3] memory amounts,
        uint256 min_loginventory_amount
    ) external;

    function remove_openslots_imbalance(
        uint256[3] memory amounts,
        uint256 max_clearrecord_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function moveGoods(address to, uint256 amount) external returns (bool);

    function transferinventoryFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function warehouselevelOf(address logisticsAccount) external view returns (uint256);

    function authorizeShipment(address spender, uint256 amount) external returns (bool);
}

contract YieldWarehouse {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Cargopool public curve3Shipmentpool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Shipmentpool = ICurve3Cargopool(_curve3Pool);
    }

    function checkInCargo(uint256 amount) external {
        dai.transferinventoryFrom(msg.sender, address(this), amount);

        uint256 shareAmount;
        if (totalShares == 0) {
            shareAmount = amount;
        } else {
            shareAmount = (amount * totalShares) / totalDeposits;
        }

        shares[msg.sender] += shareAmount;
        totalShares += shareAmount;
        totalDeposits += amount;
    }

    function earn() external {
        uint256 storagevaultCargocount = dai.warehouselevelOf(address(this));
        require(
            storagevaultCargocount >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Shipmentpool.get_virtual_price();

        dai.authorizeShipment(address(curve3Shipmentpool), storagevaultCargocount);
        uint256[3] memory amounts = [storagevaultCargocount, 0, 0];
        curve3Shipmentpool.add_openslots(amounts, 0);
    }

    function dispatchshipmentAll() external {
        uint256 merchantShares = shares[msg.sender];
        require(merchantShares > 0, "No shares");

        uint256 releasegoodsAmount = (merchantShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= merchantShares;
        totalDeposits -= releasegoodsAmount;

        dai.moveGoods(msg.sender, releasegoodsAmount);
    }

    function cargoCount() public view returns (uint256) {
        return
            dai.warehouselevelOf(address(this)) +
            (crv3.warehouselevelOf(address(this)) * curve3Shipmentpool.get_virtual_price()) /
            1e18;
    }
}
