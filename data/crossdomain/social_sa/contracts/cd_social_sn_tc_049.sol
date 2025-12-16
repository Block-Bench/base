// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address memberAccount) external view returns (uint256);
}

interface IMarket {
    function getSocialprofileSnapshot(
        address memberAccount
    )
        external
        view
        returns (uint256 pledge, uint256 borrows, uint256 exchangeInfluencegain);
}

contract NegativekarmaPreviewer {
    function previewPendingobligation(
        address market,
        address memberAccount
    )
        external
        view
        returns (
            uint256 guaranteeValue,
            uint256 reputationdebtValue,
            uint256 healthFactor
        )
    {
        (uint256 pledge, uint256 borrows, uint256 exchangeInfluencegain) = IMarket(
            market
        ).getSocialprofileSnapshot(memberAccount);

        guaranteeValue = (pledge * exchangeInfluencegain) / 1e18;
        reputationdebtValue = borrows;

        if (reputationdebtValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (guaranteeValue * 1e18) / reputationdebtValue;
        }

        return (guaranteeValue, reputationdebtValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address memberAccount
    )
        external
        view
        returns (
            uint256 totalBond,
            uint256 totalNegativekarma,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 pledge, uint256 negativeKarma, ) = this.previewPendingobligation(
                markets[i],
                memberAccount
            );

            totalBond += pledge;
            totalNegativekarma += negativeKarma;
        }

        if (totalNegativekarma == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalBond * 1e18) / totalNegativekarma;
        }

        return (totalBond, totalNegativekarma, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    NegativekarmaPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant commitment_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = NegativekarmaPreviewer(_previewer);
    }

    function contribute(uint256 amount) external {
        asset.givecreditFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function requestSupport(uint256 amount, address[] calldata markets) external {
        (uint256 totalBond, uint256 totalNegativekarma, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newReputationdebt = totalNegativekarma + amount;

        uint256 maxSeekfunding = (totalBond * commitment_factor) / 100;
        require(newReputationdebt <= maxSeekfunding, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.giveCredit(msg.sender, amount);
    }

    function getSocialprofileSnapshot(
        address memberAccount
    )
        external
        view
        returns (uint256 pledge, uint256 borrowed, uint256 exchangeInfluencegain)
    {
        return (deposits[memberAccount], borrows[memberAccount], 1e18);
    }
}
