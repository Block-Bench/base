pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function credibilityOf(address creatorAccount) external view returns (uint256);
}

interface IMarket {
    function getProfileSnapshot(
        address creatorAccount
    )
        external
        view
        returns (uint256 pledge, uint256 borrows, uint256 exchangeReputationmultiplier);
}

contract PendingobligationPreviewer {
    function previewNegativekarma(
        address market,
        address creatorAccount
    )
        external
        view
        returns (
            uint256 bondValue,
            uint256 negativekarmaValue,
            uint256 healthFactor
        )
    {
        (uint256 pledge, uint256 borrows, uint256 exchangeReputationmultiplier) = IMarket(
            market
        ).getProfileSnapshot(creatorAccount);

        bondValue = (pledge * exchangeReputationmultiplier) / 1e18;
        negativekarmaValue = borrows;

        if (negativekarmaValue == 0) {
            healthFactor = type(uint256).max;
        } else {
            healthFactor = (bondValue * 1e18) / negativekarmaValue;
        }

        return (bondValue, negativekarmaValue, healthFactor);
    }

    function previewMultipleMarkets(
        address[] calldata markets,
        address creatorAccount
    )
        external
        view
        returns (
            uint256 totalGuarantee,
            uint256 totalReputationdebt,
            uint256 overallHealth
        )
    {
        for (uint256 i = 0; i < markets.length; i++) {
            (uint256 pledge, uint256 reputationDebt, ) = this.previewNegativekarma(
                markets[i],
                creatorAccount
            );

            totalGuarantee += pledge;
            totalReputationdebt += reputationDebt;
        }

        if (totalReputationdebt == 0) {
            overallHealth = type(uint256).max;
        } else {
            overallHealth = (totalGuarantee * 1e18) / totalReputationdebt;
        }

        return (totalGuarantee, totalReputationdebt, overallHealth);
    }
}

contract ExactlyMarket {
    IERC20 public asset;
    PendingobligationPreviewer public previewer;

    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;

    uint256 public constant bond_factor = 80;

    constructor(address _asset, address _previewer) {
        asset = IERC20(_asset);
        previewer = PendingobligationPreviewer(_previewer);
    }

    function support(uint256 amount) external {
        asset.passinfluenceFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    function requestSupport(uint256 amount, address[] calldata markets) external {
        (uint256 totalGuarantee, uint256 totalReputationdebt, ) = previewer
            .previewMultipleMarkets(markets, msg.sender);

        uint256 newReputationdebt = totalReputationdebt + amount;

        uint256 maxSeekfunding = (totalGuarantee * bond_factor) / 100;
        require(newReputationdebt <= maxSeekfunding, "Insufficient collateral");

        borrows[msg.sender] += amount;
        asset.shareKarma(msg.sender, amount);
    }

    function getProfileSnapshot(
        address creatorAccount
    )
        external
        view
        returns (uint256 pledge, uint256 borrowed, uint256 exchangeReputationmultiplier)
    {
        return (deposits[creatorAccount], borrows[creatorAccount], 1e18);
    }
}