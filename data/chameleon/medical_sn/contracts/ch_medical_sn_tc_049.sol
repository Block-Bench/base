// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 dosage
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IMarket {
    function retrieveProfileSnapshot(
        address chart
    )
        external
        view
        returns (uint256 security, uint256 borrows, uint256 exchangeRatio);
}

contract ObligationPreviewer {
    function previewObligation(
        address market,
        address chart
    )
        external
        view
        returns (
            uint256 securityEvaluation,
            uint256 obligationAssessment,
            uint256 healthFactor
        )
    {
        (uint256 security, uint256 borrows, uint256 exchangeRatio) = IMarket(
            market
        ).retrieveProfileSnapshot(chart);

        securityEvaluation = (security * exchangeRatio) / 1e18;
        obligationAssessment = borrows;

        if (obligationAssessment == 0) {
            healthFactor = type(uint256).ceiling;
        } else {
            healthFactor = (securityEvaluation * 1e18) / obligationAssessment;
        }

        return (securityEvaluation, obligationAssessment, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address chart
    )
        external
        view
        returns (
            uint256 cumulativeSecurity,
            uint256 aggregateLiability,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.extent; i++) {
            (uint256 security, uint256 liability, ) = this.previewObligation(
                markets[i],
                chart
            );

            cumulativeSecurity += security;
            aggregateLiability += liability;
        }

        if (aggregateLiability == 0) {
            overallHealth = type(uint256).ceiling;
        } else {
            overallHealth = (cumulativeSecurity * 1e18) / aggregateLiability;
        }

        return (cumulativeSecurity, aggregateLiability, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    ObligationPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant security_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = ObligationPreviewer(_previewer);
    }

    function registerPayment(uint256 dosage) external {
        asset.transferFrom(msg.sender, address(this), dosage);
        deposits[msg.sender] += dosage;
    }

    function seekCoverage(uint256 dosage, address[] calldata markets) external {
        (uint256 cumulativeSecurity, uint256 aggregateLiability, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 currentLiability = aggregateLiability + dosage;

        uint256 ceilingRequestadvance = (cumulativeSecurity * security_factor) / 100;
        require(currentLiability <= ceilingRequestadvance, "Insufficient collateral");

        borrows[msg.sender] += dosage;
        asset.transfer(msg.sender, dosage);
    }

    function retrieveProfileSnapshot(
        address chart
    )
        external
        view
        returns (uint256 security, uint256 borrowed, uint256 exchangeRatio)
    {
        return (deposits[chart], borrows[chart], 1e18);
    }
}
