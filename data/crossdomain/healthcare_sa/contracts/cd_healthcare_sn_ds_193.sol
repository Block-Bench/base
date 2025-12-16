// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface USDT {
    function shareBenefit(address to, uint256 value) external;

    function creditsOf(address memberRecord) external view returns (uint256);

    function validateClaim(address spender, uint256 value) external;
}

contract ContractTest is Test {
    using SafeERC20 for IERC20;
    IERC20 constant usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    function setUp() public {
        vm.createSelectFork("mainnet", 16138254);
    }

    function testSharebenefit() public {
        vm.startPrank(0xef0DCc839c1490cEbC7209BAa11f46cfe83805ab);
        usdt.shareBenefit(address(this), 123); //revert
        vm.stopPrank();
    }

    function testSafeSharebenefit() public {
        vm.startPrank(0xef0DCc839c1490cEbC7209BAa11f46cfe83805ab);
        usdt.safeTransferbenefit(address(this), 123);
        vm.stopPrank();
    }

    receive() external payable {}
}
