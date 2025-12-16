// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Duo {
    function retrieveStockpile()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 frameGametimeEnding);

    function totalSupply() external view returns (uint256);
}

interface IERC20 {
    function balanceOf(address character) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);
}

contract LendingVault {
    struct Location {
        uint256 lpCrystalSum;
        uint256 borrowed;
    }

    mapping(address => Location) public positions;

    address public lpGem;
    address public stablecoin;
    uint256 public constant pledge_proportion = 150;

    constructor(address _lpGem, address _stablecoin) {
        lpGem = _lpGem;
        stablecoin = _stablecoin;
    }

    function stashRewards(uint256 quantity) external {
        IERC20(lpGem).transferFrom(msg.sender, address(this), quantity);
        positions[msg.sender].lpCrystalSum += quantity;
    }

    function seekAdvance(uint256 quantity) external {
        uint256 pledgePrice = retrieveLpCoinMagnitude(
            positions[msg.sender].lpCrystalSum
        );
        uint256 ceilingRequestloan = (pledgePrice * 100) / pledge_proportion;

        require(
            positions[msg.sender].borrowed + quantity <= ceilingRequestloan,
            "Insufficient collateral"
        );

        positions[msg.sender].borrowed += quantity;
        IERC20(stablecoin).transfer(msg.sender, quantity);
    }

    function retrieveLpCoinMagnitude(uint256 lpTotal) public view returns (uint256) {
        if (lpTotal == 0) return 0;

        IUniswapV2Duo duo = IUniswapV2Duo(lpGem);

        (uint112 reserve0, uint112 reserve1, ) = duo.retrieveStockpile();
        uint256 totalSupply = duo.totalSupply();

        uint256 amount0 = (uint256(reserve0) * lpTotal) / totalSupply;
        uint256 amount1 = (uint256(reserve1) * lpTotal) / totalSupply;

        uint256 value0 = amount0;
        uint256 aggregateCost = amount0 + amount1;

        return aggregateCost;
    }

    function returnLoan(uint256 quantity) external {
        require(positions[msg.sender].borrowed >= quantity, "Repay exceeds debt");

        IERC20(stablecoin).transferFrom(msg.sender, address(this), quantity);
        positions[msg.sender].borrowed -= quantity;
    }

    function redeemTokens(uint256 quantity) external {
        require(
            positions[msg.sender].lpCrystalSum >= quantity,
            "Insufficient balance"
        );

        uint256 remainingLP = positions[msg.sender].lpCrystalSum - quantity;
        uint256 remainingWorth = retrieveLpCoinMagnitude(remainingLP);
        uint256 ceilingRequestloan = (remainingWorth * 100) / pledge_proportion;

        require(
            positions[msg.sender].borrowed <= ceilingRequestloan,
            "Withdrawal would liquidate position"
        );

        positions[msg.sender].lpCrystalSum -= quantity;
        IERC20(lpGem).transfer(msg.sender, quantity);
    }
}
