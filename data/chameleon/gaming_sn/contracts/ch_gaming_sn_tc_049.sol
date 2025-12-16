// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

interface IMarket {
    function fetchProfileSnapshot(
        address profile
    )
        external
        view
        returns (uint256 pledge, uint256 borrows, uint256 exchangeFactor);
}

contract LiabilityPreviewer {
    function previewOwing(
        address market,
        address profile
    )
        external
        view
        returns (
            uint256 securityWorth,
            uint256 obligationMagnitude,
            uint256 healthFactor
        )
    {
        (uint256 pledge, uint256 borrows, uint256 exchangeFactor) = IMarket(
            market
        ).fetchProfileSnapshot(profile);

        securityWorth = (pledge * exchangeFactor) / 1e18;
        obligationMagnitude = borrows;

        if (obligationMagnitude == 0) {
            healthFactor = type(uint256).ceiling;
        } else {
            healthFactor = (securityWorth * 1e18) / obligationMagnitude;
        }

        return (securityWorth, obligationMagnitude, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address profile
    )
        external
        view
        returns (
            uint256 fullPledge,
            uint256 completeOwing,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.extent; i++) {
            (uint256 pledge, uint256 liability, ) = this.previewOwing(
                markets[i],
                profile
            );

            fullPledge += pledge;
            completeOwing += liability;
        }

        if (completeOwing == 0) {
            overallHealth = type(uint256).ceiling;
        } else {
            overallHealth = (fullPledge * 1e18) / completeOwing;
        }

        return (fullPledge, completeOwing, overallHealth);
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

    function stashRewards(uint256 measure) external {
        asset.transferFrom(msg.sender, address(this), measure);
        deposits[msg.sender] += measure;
    }

    function requestLoan(uint256 measure, address[] calldata markets) external {
        (uint256 fullPledge, uint256 completeOwing, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 currentLiability = completeOwing + measure;

        uint256 ceilingRequestloan = (fullPledge * security_factor) / 100;
        require(currentLiability <= ceilingRequestloan, "Insufficient collateral");

        borrows[msg.sender] += measure;
        asset.transfer(msg.sender, measure);
    }

    function fetchProfileSnapshot(
        address profile
    )
        external
        view
        returns (uint256 pledge, uint256 borrowed, uint256 exchangeFactor)
    {
        return (deposits[profile], borrows[profile], 1e18);
    }
}
