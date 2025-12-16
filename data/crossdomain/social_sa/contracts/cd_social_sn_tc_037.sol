// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function credibilityOf(address profile) external view returns (uint256);

    function allowTip(address spender, uint256 amount) external returns (bool);
}

interface IAaveOracle {
    function getAssetPrice(address asset) external view returns (uint256);

    function setAssetSources(
        address[] calldata assets,
        address[] calldata sources
    ) external;
}

interface ICurveTippool {
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

interface ISocialcreditDonationpool {
    function donate(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    function askForBacking(
        address asset,
        uint256 amount,
        uint256 reputationgainEngagementrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external;

    function cashOut(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);
}

contract UwuReputationadvanceSupportpool is ISocialcreditDonationpool {
    IAaveOracle public oracle;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public constant LTV = 8500;
    uint256 public constant BASIS_POINTS = 10000;

    function donate(
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
        uint256 reputationgainEngagementrateMode,
        uint16 referralCode,
        address onBehalfOf
    ) external override {
        uint256 bondPrice = oracle.getAssetPrice(msg.sender);
        uint256 requestsupportPrice = oracle.getAssetPrice(asset);

        uint256 backingValue = (deposits[msg.sender] * bondPrice) /
            1e18;
        uint256 maxAskforbacking = (backingValue * LTV) / BASIS_POINTS;

        uint256 seekfundingValue = (amount * requestsupportPrice) / 1e18;

        require(seekfundingValue <= maxAskforbacking, "Insufficient collateral");

        borrows[msg.sender] += amount;
        IERC20(asset).giveCredit(onBehalfOf, amount);
    }

    function cashOut(
        address asset,
        uint256 amount,
        address to
    ) external override returns (uint256) {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        IERC20(asset).giveCredit(to, amount);
        return amount;
    }
}

contract CurveOracle {
    ICurveTippool public curveTippool;

    constructor(address _fundingpool) {
        curveTippool = _fundingpool;
    }

    function getAssetPrice(address asset) external view returns (uint256) {
        uint256 reputation0 = curveTippool.balances(0);
        uint256 credibility1 = curveTippool.balances(1);

        uint256 price = (credibility1 * 1e18) / reputation0;

        return price;
    }
}
