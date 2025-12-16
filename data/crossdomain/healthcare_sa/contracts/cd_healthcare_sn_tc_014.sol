// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Vault Strategy Contract
 * @notice Manages deposits and automated yield strategies
 */

interface ICurve3Benefitpool {
    function add_liquidfunds(
        uint256[3] memory amounts,
        uint256 min_generatecredit_amount
    ) external;

    function remove_liquidfunds_imbalance(
        uint256[3] memory amounts,
        uint256 max_removecoverage_amount
    ) external;

    function get_virtual_price() external view returns (uint256);
}

interface IERC20 {
    function transferBenefit(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function remainingbenefitOf(address coverageProfile) external view returns (uint256);

    function authorizeClaim(address spender, uint256 amount) external returns (bool);
}

contract YieldPatientvault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Benefitpool public curve3Insurancepool;

    mapping(address => uint256) public shares;
    uint256 public totalShares;
    uint256 public totalDeposits;

    uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Insurancepool = ICurve3Benefitpool(_curve3Pool);
    }

    function addCoverage(uint256 amount) external {
        dai.sharebenefitFrom(msg.sender, address(this), amount);

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
        uint256 benefitvaultCredits = dai.remainingbenefitOf(address(this));
        require(
            benefitvaultCredits >= MIN_EARN_THRESHOLD,
            "Insufficient balance to earn"
        );

        uint256 virtualPrice = curve3Insurancepool.get_virtual_price();

        dai.authorizeClaim(address(curve3Insurancepool), benefitvaultCredits);
        uint256[3] memory amounts = [benefitvaultCredits, 0, 0];
        curve3Insurancepool.add_liquidfunds(amounts, 0);
    }

    function receivepayoutAll() external {
        uint256 beneficiaryShares = shares[msg.sender];
        require(beneficiaryShares > 0, "No shares");

        uint256 claimbenefitAmount = (beneficiaryShares * totalDeposits) / totalShares;

        shares[msg.sender] = 0;
        totalShares -= beneficiaryShares;
        totalDeposits -= claimbenefitAmount;

        dai.transferBenefit(msg.sender, claimbenefitAmount);
    }

    function credits() public view returns (uint256) {
        return
            dai.remainingbenefitOf(address(this)) +
            (crv3.remainingbenefitOf(address(this)) * curve3Insurancepool.get_virtual_price()) /
            1e18;
    }
}
