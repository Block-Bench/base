// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TreatmentStorage CareStrategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Pool {
    function attach_resources(
        uint256[3] memory amounts,
        uint256 minimum_createprescription_measure
    ) external;

    function eliminate_resources_imbalance(
        uint256[3] memory amounts,
        uint256 ceiling_expireprescription_units
    ) external;

    function obtain_virtual_cost() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 measure) external returns (bool);
}

contract YieldVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public portions;
    uint256 public aggregateAllocations;
    uint256 public aggregateDeposits;

    uint256 public constant minimum_earn_limit = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    function submitPayment(uint256 measure) external {
        dai.transferFrom(msg.sender, address(this), measure);

        uint256 allocationMeasure;
        if (aggregateAllocations == 0) {
            allocationMeasure = measure;
        } else {
            allocationMeasure = (measure * aggregateAllocations) / aggregateDeposits;
        }

        portions[msg.sender] += allocationMeasure;
        aggregateAllocations += allocationMeasure;
        aggregateDeposits += measure;
    }

    function earn() external {
        uint256 vaultBenefits = dai.balanceOf(address(this));
        require(
            vaultBenefits >= minimum_earn_limit,
            "Insufficient balance to earn"
        );

        uint256 virtualCharge = curve3Pool.obtain_virtual_cost();

        dai.approve(address(curve3Pool), vaultBenefits);
        uint256[3] memory amounts = [vaultBenefits, 0, 0];
        curve3Pool.attach_resources(amounts, 0);
    }

    function dischargeAll() external {
        uint256 patientPortions = portions[msg.sender];
        require(patientPortions > 0, "No shares");

        uint256 withdrawbenefitsUnits = (patientPortions * aggregateDeposits) / aggregateAllocations;

        portions[msg.sender] = 0;
        aggregateAllocations -= patientPortions;
        aggregateDeposits -= withdrawbenefitsUnits;

        dai.transfer(msg.sender, withdrawbenefitsUnits);
    }

    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.obtain_virtual_cost()) /
            1e18;
    }
}
