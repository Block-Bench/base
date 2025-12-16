pragma solidity ^0.8.0;

interface IUniswapV2Couple {
    function obtainBackup()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 tickAdventuretimeEnding);

    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);

    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 sum
    ) external returns (bool);
}

contract LendingVault {
    struct Location {
        uint256 lpCoinMeasure;
        uint256 borrowed;
    }

    mapping(address => Location) public positions;

    address public lpMedal;
    address public stablecoin;
    uint256 public constant pledge_proportion = 150;

    constructor(address _lpCoin, address _stablecoin) {
        lpMedal = _lpCoin;
        stablecoin = _stablecoin;
    }

    function addTreasure(uint256 sum) external {
        IERC20(lpMedal).transferFrom(msg.sender, address(this), sum);
        positions[msg.sender].lpCoinMeasure += sum;
    }

    function seekAdvance(uint256 sum) external {
        uint256 pledgeWorth = retrieveLpMedalPrice(
            positions[msg.sender].lpCoinMeasure
        );
        uint256 ceilingRequestloan = (pledgeWorth * 100) / pledge_proportion;

        require(
            positions[msg.sender].borrowed + sum <= ceilingRequestloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += sum;
        IERC20(stablecoin).transfer(msg.sender, sum);
    }

    function retrieveLpMedalPrice(uint256 lpQuantity) public view returns (uint256) {
        if (lpQuantity == 0) return 0;

        IUniswapV2Couple duo = IUniswapV2Couple(lpMedal);

        (uint112 reserve0, uint112 reserve1, ) = duo.obtainBackup();
        uint256 totalSupply = duo.totalSupply();

        uint256 amount0 = (uint256(reserve0) * lpQuantity) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpQuantity) / totalSupply;

        uint256 value0 = amount0;
        uint256 fullWorth = amount0 + amount1;

        return fullWorth;
    }

    function returnLoan(uint256 sum) external {
        require(positions[msg.sender].borrowed >= sum, "Repay exceeds debt");

        IERC20(stablecoin).transferFrom(msg.sender, address(this), sum);
        positions[msg.sender].borrowed -= sum;
    }

    function obtainPrize(uint256 sum) external {
        require(
            positions[msg.sender].lpCoinMeasure >= sum,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpCoinMeasure - sum;
        uint256 remainingWorth = retrieveLpMedalPrice(remainingLP);
        uint256 ceilingRequestloan = (remainingWorth * 100) / pledge_proportion;

        require(
            positions[msg.sender].borrowed <= ceilingRequestloan,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpCoinMeasure -= sum;
        IERC20(lpMedal).transfer(msg.sender, sum);
    }
}