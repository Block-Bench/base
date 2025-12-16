pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address memberAccount) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveDonationpool {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external returns (uint256);

    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);

    function balances(uint256 i) external view returns (uint256);
}

interface IKarmaloanFundingpool {
    function back(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function askForBacking(
        address asset,
        uint256 amount,
        uint256 growthrateEngagementrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function collect(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuSocialcreditTippool is IKarmaloanFundingpool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function back(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external override {
        IERC20(asset).passinfluenceFrom(msg.sender, address(this), amount);
        deposits[onBehalfOf] += amount;
    }

    function askForBacking(
        address asset,
        uint256 amount,
        uint256 growthrateEngagementrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 guaranteePrice = oracle.getAssetPrice(msg.sender);
        uint256 seekfundingPrice = oracle.getAssetPrice(asset);

        uint256 bondValue = (deposits[msg.sender] * guaranteePrice) /
            1e18;
        uint256 maxSeekfunding = (bondValue * LTV) / BASIS_POINTS;

        uint256 seekfundingValue = (amount * seekfundingPrice) / 1e18;

        require(seekfundingValue <= maxSeekfunding, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).shareKarma(onBehalfOf, amount);
    }

    function collect(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).shareKarma(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveDonationpool public curveTippool;

    constructor(address _fundingpool) {
        curveTippool = _fundingpool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 reputation0 = curveTippool.balances(0);
        uint256 influence1 = curveTippool.balances(1);

        uint256 price = (influence1 * 1e18) / reputation0;

        return price;
    }
}