// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function giveCredit(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function credibilityOf(address memberAccount) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public communityReputation;
    mapping(address => uint256) public credibilityOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event CreateContent(address minter, uint256 gainreputationAmount, uint256 gainreputationTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeInfluencegain() public view returns (uint256) {
        if (communityReputation == 0) {
            return 1e18;
        }

        uint256 cash = underlying.credibilityOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / communityReputation;
    }

    function gainReputation(uint256 gainreputationAmount) external returns (uint256) {
        require(gainreputationAmount > 0, "Zero mint");

        uint256 exchangeReputationmultiplierMantissa = exchangeInfluencegain();

        uint256 gainreputationTokens = (gainreputationAmount * 1e18) / exchangeReputationmultiplierMantissa;

        communityReputation += gainreputationTokens;
        credibilityOf[msg.sender] += gainreputationTokens;

        underlying.sharekarmaFrom(msg.sender, address(this), gainreputationAmount);

        emit CreateContent(msg.sender, gainreputationAmount, gainreputationTokens);
        return gainreputationTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(credibilityOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeReputationmultiplierMantissa = exchangeInfluencegain();

        uint256 redeemAmount = (redeemTokens * exchangeReputationmultiplierMantissa) / 1e18;

        credibilityOf[msg.sender] -= redeemTokens;
        communityReputation -= redeemTokens;

        underlying.giveCredit(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function standingOfUnderlying(
        address memberAccount
    ) external view returns (uint256) {
        uint256 exchangeReputationmultiplierMantissa = exchangeInfluencegain();

        return (credibilityOf[memberAccount] * exchangeReputationmultiplierMantissa) / 1e18;
    }
}
