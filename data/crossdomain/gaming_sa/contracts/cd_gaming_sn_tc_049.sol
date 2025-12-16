// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function tradeLoot(address to, uint256 amount) external returns (bool);

    function tradelootFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function goldholdingOf(address gamerProfile) external view returns (uint256);
}

interface IMarket {
    function getPlayeraccountSnapshot(
        address gamerProfile
    )
        external
        view
        returns (uint256 wager, uint256 borrows, uint256 exchangeScoremultiplier);
}

contract GolddebtPreviewer {
    function previewOwedgold(
        address market,
        address gamerProfile
    )
        external
        view
        returns (
            uint256 depositValue,
            uint256 loanamountValue,
            uint256 healthFactor
        )
    {
        (uint256 wager, uint256 borrows, uint256 exchangeScoremultiplier) = IMarket(
            market
        ).getPlayeraccountSnapshot(gamerProfile);

        depositValue = (wager * exchangeScoremultiplier) / 1e18;
        loanamountValue = borrows;

        if (loanamountValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (depositValue * 1e18) / loanamountValue;
        }

        return (depositValue, loanamountValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address gamerProfile
    )
        external
        view
        returns (
            uint256 totalBet,
            uint256 totalGolddebt,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 wager, uint256 goldDebt, ) = this.previewOwedgold(
                markets[i],
                gamerProfile
            );

            totalBet += wager;
            totalGolddebt += goldDebt;
        }

        if (totalGolddebt == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalBet * 1e18) / totalGolddebt;
        }

        return (totalBet, totalGolddebt, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    GolddebtPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant stake_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = GolddebtPreviewer(_previewer);
    }

    function storeLoot(uint256 amount) external {
        asset.tradelootFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function requestLoan(uint256 amount, address[] calldata markets) external {
        (uint256 totalBet, uint256 totalGolddebt, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newLoanamount = totalGolddebt + amount;

        uint256 maxGetloan = (totalBet * stake_factor) / 100;
        require(newLoanamount <= maxGetloan, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.tradeLoot(msg.sender, amount);
    }

    function getPlayeraccountSnapshot(
        address gamerProfile
    )
        external
        view
        returns (uint256 wager, uint256 borrowed, uint256 exchangeScoremultiplier)
    {
        return (deposits[gamerProfile], borrows[gamerProfile], 1e18);
    }
}
