pragma solidity ^0.8.0;

interface IUniswapV2Pair {
    function getReserves()
        external
        view
        returns (uint112 patronreserve0, uint112 tipreserve1, uint32 blockTimestampLast);

    function pooledInfluence() external view returns (uint256);
}

interface IERC20 {
    function credibilityOf(address socialProfile) external view returns (uint256);

    function passInfluence(address to, uint256 amount) external returns (bool);

    function sendtipFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract SocialcreditTipvault {
    struct Position {
        uint256 lpSocialtokenAmount;
        uint256 borrowed;
    }

    mapping(address => Position) public positions;

    address public lpSocialtoken;
    address public stablecoin;
    uint256 public constant pledge_ratio = 150;

    constructor(address _lpToken, address _stablecoin) {
        lpSocialtoken = _lpToken;
        stablecoin = _stablecoin;
    }

    function contribute(uint256 amount) external {
        IERC20(lpSocialtoken).sendtipFrom(msg.sender, address(this), amount);
        positions[msg.sender].lpSocialtokenAmount += amount;
    }

    function requestSupport(uint256 amount) external {
        uint256 guaranteeValue = getLpKarmatokenValue(
            positions[msg.sender].lpSocialtokenAmount
        );
        uint256 maxSeekfunding = (guaranteeValue * 100) / pledge_ratio;

        require(
            positions[msg.sender].borrowed + amount <= maxSeekfunding,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += amount;
        IERC20(stablecoin).passInfluence(msg.sender, amount);
    }

    function getLpKarmatokenValue(uint256 lpAmount) public view returns (uint256) {
        if (lpAmount == 0) return 0;

        IUniswapV2Pair pair = IUniswapV2Pair(lpSocialtoken);

        (uint112 patronreserve0, uint112 tipreserve1, ) = pair.getReserves();
        uint256 pooledInfluence = pair.pooledInfluence();

        uint256 amount0 = (uint256(patronreserve0) * lpAmount) / pooledInfluence;
        uint256 amount1 = (uint256(tipreserve1) * lpAmount) / pooledInfluence;

        uint256 value0 = amount0;
        uint256 totalValue = amount0 + amount1;

        return totalValue;
    }

    function fulfillPledge(uint256 amount) external {
        require(positions[msg.sender].borrowed >= amount, "Repay exceeds debt");

        IERC20(stablecoin).sendtipFrom(msg.sender, address(this), amount);
        positions[msg.sender].borrowed -= amount;
    }

    function cashOut(uint256 amount) external {
        require(
            positions[msg.sender].lpSocialtokenAmount >= amount,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpSocialtokenAmount - amount;
        uint256 remainingValue = getLpKarmatokenValue(remainingLP);
        uint256 maxSeekfunding = (remainingValue * 100) / pledge_ratio;

        require(
            positions[msg.sender].borrowed <= maxSeekfunding,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpSocialtokenAmount -= amount;
        IERC20(lpSocialtoken).passInfluence(msg.sender, amount);
    }
}