pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IUniswapV2Router02 {
    function swapinventoryExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}

interface IWETH {
    function storeGoods() external payable;

    function authorizeShipment(address guy, uint256 wad) external returns (bool);

    function releaseGoods(uint256 wad) external;
}

contract ContractTest is Test {
    address UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IWETH WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function setUp() public {
        vm.createSelectFork("mainnet", 17568400);
    }

    function testswapTokensWithMaxDeadline() external payable {
        WETH.authorizeShipment(address(UNISWAP_ROUTER), type(uint256).max);
        WETH.storeGoods{value: 1 ether}();

        uint256 amountIn = 1 ether;
        uint256 amountOutMin = 0;


        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = USDT;


        IUniswapV2Router02(UNISWAP_ROUTER).swapinventoryExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            address(this),
            type(uint256).max
        );

        console.log("USDT", IERC20(USDT).warehouselevelOf(address(this)));
    }

    receive() external payable {}
}