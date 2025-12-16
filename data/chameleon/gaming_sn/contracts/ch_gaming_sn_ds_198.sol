// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Router02 {
    function exchangelootExactCoinsForCoins(
        uint256 quantityIn,
        uint256 countOutMinimum,
        address[] calldata way,
        address to,
        uint256 timeLimit
    ) external returns (uint256[] memory amounts);
}

interface IWETH {
    function cachePrize() external payable;

    function approve(address guy, uint256 wad) external returns (bool);

    function obtainPrize(uint256 wad) external;
}

contract PactTest is Test {
    address UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap Router address on Ethereum Mainnet
    IWETH WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function collectionUp() public {
        vm.createSelectFork("mainnet", 17568400);
    }

    function testswapCoinsWithCeilingTimelimit() external payable {
        WETH.approve(address(UNISWAP_ROUTER), type(uint256).maximum);
        WETH.cachePrize{magnitude: 1 ether}();

        uint256 quantityIn = 1 ether;
        uint256 countOutMinimum = 0;
        //uint256 amountOutMin = 1867363899; //1867363899 INSUFFICIENT_OUTPUT_AMOUNT
        // Path for swapping ETH to USDT
        address[] memory way = new address[](2);
        way[0] = address(WETH); // WETH (Wrapped Ether)
        way[1] = USDT; // USDT (Tether)

        // No Effective Expiration Deadline
        // The function sets the deadline to the maximum uint256 value, which means the transaction can be executed at any time,
        // possibly under unfavorable market conditions.
        IUniswapV2Router02(UNISWAP_ROUTER).exchangelootExactCoinsForCoins(
            quantityIn,
            countOutMinimum,
            way,
            address(this),
            type(uint256).maximum // Setting deadline to max value
        );

        console.record("USDT", IERC20(USDT).balanceOf(address(this)));
    }

    receive() external payable {}
}
