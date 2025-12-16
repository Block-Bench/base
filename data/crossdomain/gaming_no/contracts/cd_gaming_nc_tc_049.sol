pragma solidity ^0.8.0;

interface IERC20 {
    function giveItems(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function itemcountOf(address gamerProfile) external view returns (uint256);
}

interface IMarket {
    function getPlayeraccountSnapshot(
        address gamerProfile
    )
        external
        view
        returns (uint256 wager, uint256 borrows, uint256 exchangeBonusrate);
}

contract OwedgoldPreviewer {
    function previewGolddebt(
        address market,
        address gamerProfile
    )
        external
        view
        returns (
            uint256 betValue,
            uint256 golddebtValue,
            uint256 healthFactor
        )
    {
        (uint256 wager, uint256 borrows, uint256 exchangeBonusrate) = IMarket(
            market
        ).getPlayeraccountSnapshot(gamerProfile);

        betValue = (wager * exchangeBonusrate) / 1e18;
        golddebtValue = borrows;

        if (golddebtValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (betValue * 1e18) / golddebtValue;
        }

        return (betValue, golddebtValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address gamerProfile
    )
        external
        view
        returns (
            uint256 totalDeposit,
            uint256 totalLoanamount,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 wager, uint256 loanAmount, ) = this.previewGolddebt(
                markets[i],
                gamerProfile
            );

            totalDeposit += wager;
            totalLoanamount += loanAmount;
        }

        if (totalLoanamount == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalDeposit * 1e18) / totalLoanamount;
        }

        return (totalDeposit, totalLoanamount, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    OwedgoldPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant bet_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = OwedgoldPreviewer(_previewer);
    }

    function savePrize(uint256 amount) external {
        asset.sharetreasureFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function borrowGold(uint256 amount, address[] calldata markets) external {
        (uint256 totalDeposit, uint256 totalLoanamount, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newLoanamount = totalLoanamount + amount;

        uint256 maxGetloan = (totalDeposit * bet_factor) / 100;
        require(newLoanamount <= maxGetloan, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.giveItems(msg.sender, amount);
    }

    function getPlayeraccountSnapshot(
        address gamerProfile
    )
        external
        view
        returns (uint256 wager, uint256 borrowed, uint256 exchangeBonusrate)
    {
        return (deposits[gamerProfile], borrows[gamerProfile], 1e18);
    }
}