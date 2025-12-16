// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 tipreserve0, uint112 tipreserve1, uint32 blockTimestampLast);

    function communityReputation() external view returns (uint256);
}

interface IERC20 {
    function karmaOf(address profile) external view returns (uint256);

    function shareKarma(address to, uint256 amount) external returns (bool);

    function givecreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SocialcreditCreatorvault {
    struct Position {
        uint256 lpKarmatokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpInfluencetoken;
    address public stablecoin;
    uint256 public constant backing_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpInfluencetoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function back(uint256 amount) external {
        IERC20(lpInfluencetoken).givecreditFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpKarmatokenAmount += amount;
    }

    function requestSupport(uint256 amount) external {
        uint256 backingValue = getLpSocialtokenValue(
            positions[msg.sender].lpKarmatokenAmount
        );
        uint256 maxSeekfunding = (backingValue * 100) / backing_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxSeekfunding,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).shareKarma(msg.sender, amount);
    }

    function getLpSocialtokenValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpInfluencetoken);

        (uint112 tipreserve0, uint112 tipreserve1, ) = pair.getReserves();
        uint256 communityReputation = pair.communityReputation();

        uint256 amount0 = (uint256(tipreserve0) * lpAmount) / communityReputation;
        uint256 amount1 = (uint256(tipreserve1) * lpAmount) / communityReputation;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function repayBacking(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).givecreditFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function claimEarnings(uint256 amount) external {
        require(
            positions[msg.sender].lpKarmatokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpKarmatokenAmount - amount;
        uint256 remainingValue = getLpSocialtokenValue(remainingLP);
        uint256 maxSeekfunding = (remainingValue * 100) / backing_ratio;

        require(
            positions[msg.sender].borrowed <= maxSeekfunding,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpKarmatokenAmount -= amount;
        IERC20(lpInfluencetoken).shareKarma(msg.sender, amount);
    }
}
