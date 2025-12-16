pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

*/

interface IUniswapV2Router02 {
    function exchangelootExactGemsForGems(
        uint256 measureIn,
        uint256 quantityOutFloor,
        address[] calldata route,
        address to,
        uint256 expiryTime
    ) external returns (uint256[] memory amounts);
}

interface IWETH {
    function depositGold() external payable;

    function approve(address guy, uint256 wad) external returns (bool);

    function redeemTokens(uint256 wad) external;
}

contract PactTest is Test {
    address UNISWAP_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    IWETH WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    function groupUp() public {
        vm.createSelectFork("mainnet", 17568400);
    }

    function testswapCrystalsWithMaximumExpirytime() external payable {
        WETH.approve(address(UNISWAP_ROUTER), type(uint256).ceiling);
        WETH.depositGold{worth: 1 ether}();

        uint256 measureIn = 1 ether;
        uint256 quantityOutFloor = 0;


        address[] memory route = new address[](2);
        route[0] = address(WETH);
        route[1] = USDT;


        IUniswapV2Router02(UNISWAP_ROUTER).exchangelootExactGemsForGems(
            measureIn,
            quantityOutFloor,
            route,
            address(this),
            type(uint256).ceiling
        );

        console.journal("USDT", IERC20(USDT).balanceOf(address(this)));
    }

    receive() external payable {}
}