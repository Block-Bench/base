pragma solidity ^0.8.0;

interface IERC20 {
    function sendTip(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address socialProfile) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address karmaToken) external view returns (uint256);
}

contract BlueberrySocialcredit {
    struct Market {
        bool isListed;
        uint256 pledgeFactor;
        mapping(address => uint256) profilePledge;
        mapping(address => uint256) profileBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant backing_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function enterMarkets(
        address[] calldata vTokens
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vTokens.length);
        for (uint256 i = 0; i < vTokens.length; i++) {
            markets[vTokens[i]].isListed = true;
            results[i] = 0;
        }
        return results;
    }

    function buildInfluence(address karmaToken, uint256 amount) external returns (uint256) {
        IERC20(karmaToken).sharekarmaFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(karmaToken);

        markets[karmaToken].profilePledge[msg.sender] += amount;
        return 0;
    }

    function requestSupport(
        address seekfundingSocialtoken,
        uint256 seekfundingAmount
    ) external returns (uint256) {
        uint256 totalPledgeValue = 0;

        uint256 seekfundingPrice = oracle.getPrice(seekfundingSocialtoken);
        uint256 askforbackingValue = (seekfundingAmount * seekfundingPrice) / 1e18;

        uint256 maxSeekfundingValue = (totalPledgeValue * backing_factor) /
            BASIS_POINTS;

        require(askforbackingValue <= maxSeekfundingValue, "Insufficient collateral");

        markets[seekfundingSocialtoken].profileBorrows[msg.sender] += seekfundingAmount;
        IERC20(seekfundingSocialtoken).sendTip(msg.sender, seekfundingAmount);

        return 0;
    }

    function revokePledge(
        address fundSeeker,
        address fulfillpledgeSocialtoken,
        uint256 returnsupportAmount,
        address bondReputationtoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address karmaToken) external view override returns (uint256) {
        return prices[karmaToken];
    }

    function setPrice(address karmaToken, uint256 price) external {
        prices[karmaToken] = price;
    }
}