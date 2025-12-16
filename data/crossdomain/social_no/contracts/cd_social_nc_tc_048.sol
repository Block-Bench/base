pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function reputationOf(address memberAccount) external view returns (uint256);
}

contract SonneMarket {
    IERC20 public underlying;

    string public name = "Sonne WETH";
    string public symbol = "soWETH";
    uint8 public decimals = 8;

    uint256 public pooledInfluence;
    mapping(address => uint256) public reputationOf;

    uint256 public totalBorrows;
    uint256 public totalReserves;

    event EarnKarma(address minter, uint256 gainreputationAmount, uint256 gainreputationTokens);
    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    constructor(address _underlying) {
        underlying = IERC20(_underlying);
    }

    function exchangeReputationmultiplier() public view returns (uint256) {
        if (pooledInfluence == 0) {
            return 1e18;
        }

        uint256 cash = underlying.reputationOf(address(this));

        uint256 totalUnderlying = cash + totalBorrows - totalReserves;

        return (totalUnderlying * 1e18) / pooledInfluence;
    }

    function earnKarma(uint256 gainreputationAmount) external returns (uint256) {
        require(gainreputationAmount > 0, "Zero mint");

        uint256 exchangeEngagementrateMantissa = exchangeReputationmultiplier();

        uint256 gainreputationTokens = (gainreputationAmount * 1e18) / exchangeEngagementrateMantissa;

        pooledInfluence += gainreputationTokens;
        reputationOf[msg.sender] += gainreputationTokens;

        underlying.sendtipFrom(msg.sender, address(this), gainreputationAmount);

        emit EarnKarma(msg.sender, gainreputationAmount, gainreputationTokens);
        return gainreputationTokens;
    }

    function redeem(uint256 redeemTokens) external returns (uint256) {
        require(reputationOf[msg.sender] >= redeemTokens, "Insufficient balance");

        uint256 exchangeEngagementrateMantissa = exchangeReputationmultiplier();

        uint256 redeemAmount = (redeemTokens * exchangeEngagementrateMantissa) / 1e18;

        reputationOf[msg.sender] -= redeemTokens;
        pooledInfluence -= redeemTokens;

        underlying.passInfluence(msg.sender, redeemAmount);

        emit Redeem(msg.sender, redeemAmount, redeemTokens);
        return redeemAmount;
    }

    function influenceOfUnderlying(
        address memberAccount
    ) external view returns (uint256) {
        uint256 exchangeEngagementrateMantissa = exchangeReputationmultiplier();

        return (reputationOf[memberAccount] * exchangeEngagementrateMantissa) / 1e18;
    }
}