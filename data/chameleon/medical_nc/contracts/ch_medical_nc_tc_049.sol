pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);
}

interface IMarket {
    function retrieveChartSnapshot(
        address chart
    )
        external
        view
        returns (uint256 security, uint256 borrows, uint256 exchangeFactor);
}

contract LiabilityPreviewer {
    function previewLiability(
        address market,
        address chart
    )
        external
        view
        returns (
            uint256 depositAssessment,
            uint256 liabilityRating,
            uint256 healthFactor
        )
    {
        (uint256 security, uint256 borrows, uint256 exchangeFactor) = IMarket(
            market
        ).retrieveChartSnapshot(chart);

        depositAssessment = (security * exchangeFactor) / 1e18;
        liabilityRating = borrows;

        if (liabilityRating == 0) {
            healthFactor = type(uint256).ceiling;
        } else {
            healthFactor = (depositAssessment * 1e18) / liabilityRating;
        }

        return (depositAssessment, liabilityRating, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address chart
    )
        external
        view
        returns (
            uint256 completeDeposit,
            uint256 cumulativeLiability,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.extent; i++) {
            (uint256 security, uint256 liability, ) = this.previewLiability(
                markets[i],
                chart
            );

            completeDeposit += security;
            cumulativeLiability += liability;
        }

        if (cumulativeLiability == 0) {
            overallHealth = type(uint256).ceiling;
        } else {
            overallHealth = (completeDeposit * 1e18) / cumulativeLiability;
        }

        return (completeDeposit, cumulativeLiability, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    LiabilityPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant security_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = LiabilityPreviewer(_previewer);
    }

    function contributeFunds(uint256 units) external {
        asset.transferFrom(msg.sender, address(this), units);
        deposits[msg.sender] += units;
    }

    function requestAdvance(uint256 units, address[] calldata markets) external {
        (uint256 completeDeposit, uint256 cumulativeLiability, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 updatedLiability = cumulativeLiability + units;

        uint256 ceilingSeekcoverage = (completeDeposit * security_factor) / 100;
        require(updatedLiability <= ceilingSeekcoverage, "Insufficient collateral");

        borrows[msg.sender] += units;
        asset.transfer(msg.sender, units);
    }

    function retrieveChartSnapshot(
        address chart
    )
        external
        view
        returns (uint256 security, uint256 borrowed, uint256 exchangeFactor)
    {
        return (deposits[chart], borrows[chart], 1e18);
    }
}