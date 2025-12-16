// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address memberAccount) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface IPriceOracle {
    function getPrice(address influenceToken) external view returns (uint256);
}

contract BlueberryKarmaloan {
    struct Market {
        bool isListed;
        uint256 bondFactor;
        mapping(address => uint256) memberaccountGuarantee;
        mapping(address => uint256) creatoraccountBorrows;
    }

    mapping(address => Market) public markets;
    IPriceOracle public oracle;

    uint256 public constant guarantee_factor = 75;
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

    function createContent(address influenceToken, uint256 amount) external returns (uint256) {
        IERC20(influenceToken).givecreditFrom(msg.sender, address(this), amount);

        uint256 price = oracle.getPrice(influenceToken);

        markets[influenceToken].memberaccountGuarantee[msg.sender] += amount;
        return 0;
    }

    function askForBacking(
        address askforbackingInfluencetoken,
        uint256 requestsupportAmount
    ) external returns (uint256) {
        uint256 totalCommitmentValue = 0;

        uint256 askforbackingPrice = oracle.getPrice(askforbackingInfluencetoken);
        uint256 askforbackingValue = (requestsupportAmount * askforbackingPrice) / 1e18;

        uint256 maxAskforbackingValue = (totalCommitmentValue * guarantee_factor) /
            BASIS_POINTS;

        require(askforbackingValue <= maxAskforbackingValue, "Insufficient collateral");

        markets[askforbackingInfluencetoken].creatoraccountBorrows[msg.sender] += requestsupportAmount;
        IERC20(askforbackingInfluencetoken).shareKarma(msg.sender, requestsupportAmount);

        return 0;
    }

    function withdrawEndorsement(
        address fundSeeker,
        address repaybackingInfluencetoken,
        uint256 repaybackingAmount,
        address bondReputationtoken
    ) external {}
}

contract ManipulableOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function getPrice(address influenceToken) external view override returns (uint256) {
        return prices[influenceToken];
    }

    function setPrice(address influenceToken, uint256 price) external {
        prices[influenceToken] = price;
    }
}
