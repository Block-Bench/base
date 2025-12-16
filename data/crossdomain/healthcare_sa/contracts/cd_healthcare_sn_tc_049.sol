// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareBenefit(address to, uint256 amount) external returns (bool);

    function sharebenefitFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address memberRecord) external view returns (uint256);
}

interface IMarket {
    function getPatientaccountSnapshot(
        address memberRecord
    )
        external
        view
        returns (uint256 copay, uint256 borrows, uint256 exchangePremiumrate);
}

contract OutstandingbalancePreviewer {
    function previewOwedamount(
        address market,
        address memberRecord
    )
        external
        view
        returns (
            uint256 healthbondValue,
            uint256 unpaidpremiumValue,
            uint256 healthFactor
        )
    {
        (uint256 copay, uint256 borrows, uint256 exchangePremiumrate) = IMarket(
            market
        ).getPatientaccountSnapshot(memberRecord);

        healthbondValue = (copay * exchangePremiumrate) / 1e18;
        unpaidpremiumValue = borrows;

        if (unpaidpremiumValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (healthbondValue * 1e18) / unpaidpremiumValue;
        }

        return (healthbondValue, unpaidpremiumValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address memberRecord
    )
        external
        view
        returns (
            uint256 totalDeposit,
            uint256 totalOutstandingbalance,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 copay, uint256 outstandingBalance, ) = this.previewOwedamount(
                markets[i],
                memberRecord
            );

            totalDeposit += copay;
            totalOutstandingbalance += outstandingBalance;
        }

        if (totalOutstandingbalance == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalDeposit * 1e18) / totalOutstandingbalance;
        }

        return (totalDeposit, totalOutstandingbalance, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OutstandingbalancePreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant deductible_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OutstandingbalancePreviewer(_previewer);
    }

    function contributePremium(uint256 amount) external {
        asset.sharebenefitFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function requestAdvance(uint256 amount, address[] calldata markets) external {
        (uint256 totalDeposit, uint256 totalOutstandingbalance, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newUnpaidpremium = totalOutstandingbalance + amount;

        uint256 maxAccesscredit = (totalDeposit * deductible_factor) / 100;
        require(newUnpaidpremium <= maxAccesscredit, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.shareBenefit(msg.sender, amount);
    }

    function getPatientaccountSnapshot(
        address memberRecord
    )
        external
        view
        returns (uint256 copay, uint256 borrowed, uint256 exchangePremiumrate)
    {
        return (deposits[memberRecord], borrows[memberRecord], 1e18);
    }
}
