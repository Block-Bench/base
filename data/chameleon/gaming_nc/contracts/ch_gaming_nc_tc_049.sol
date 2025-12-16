pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

interface IMarket {
    function obtainCharacterSnapshot(
        address character
    )
        external
        view
        returns (uint256 security, uint256 borrows, uint256 exchangeMultiplier);
}

contract OwingPreviewer {
    function previewLiability(
        address market,
        address character
    )
        external
        view
        returns (
            uint256 pledgeCost,
            uint256 liabilityWorth,
            uint256 healthFactor
        )
    {
        (uint256 security, uint256 borrows, uint256 exchangeMultiplier) = IMarket(
            market
        ).obtainCharacterSnapshot(character);

        pledgeCost = (security * exchangeMultiplier) / 1e18;
        liabilityWorth = borrows;

        if (liabilityWorth == 0) {
            healthFactor = type(uint256).maximum;
        } else {
            healthFactor = (pledgeCost * 1e18) / liabilityWorth;
        }

        return (pledgeCost, liabilityWorth, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address character
    )
        external
        view
        returns (
            uint256 completeDeposit,
            uint256 combinedObligation,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.extent; i++) {
            (uint256 security, uint256 owing, ) = this.previewLiability(
                markets[i],
                character
            );

            completeDeposit += security;
            combinedObligation += owing;
        }

        if (combinedObligation == 0) {
            overallHealth = type(uint256).maximum;
        } else {
            overallHealth = (completeDeposit * 1e18) / combinedObligation;
        }

        return (completeDeposit, combinedObligation, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OwingPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant deposit_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OwingPreviewer(_previewer);
    }

    function storeLoot(uint256 count) external {
        asset.transferFrom(msg.initiator, address(this), count);
        deposits[msg.initiator] += count;
    }

    function requestLoan(uint256 count, address[] calldata markets) external {
        (uint256 completeDeposit, uint256 combinedObligation, ) = previewer
            .previewMultipleMarkets(markets, msg.initiator);

        uint256 currentLiability = combinedObligation + count;

        uint256 maximumRequestloan = (completeDeposit * deposit_factor) / 100;
        require(currentLiability <= maximumRequestloan, "Insufficient collateral");

        borrows[msg.initiator] += count;
        asset.transfer(msg.initiator, count);
    }

    function obtainCharacterSnapshot(
        address character
    )
        external
        view
        returns (uint256 security, uint256 borrowed, uint256 exchangeMultiplier)
    {
        return (deposits[character], borrows[character], 1e18);
    }
}