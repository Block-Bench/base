// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function moveCoverage(address to, uint256 amount) external returns (bool);

    function movecoverageFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function benefitsOf(address memberRecord) external view returns (uint256);

    function permitPayout(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function addCoverage() external payable;

    function claimBenefit(uint256 amount) external;

    function benefitsOf(address memberRecord) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3TradecoverageCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address coveragetokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (coveragetokenIn == address(WETH)) {
            WETH.claimBenefit(amountToPay);
            payable(recipient).moveCoverage(amountToPay);
        } else {
            IERC20(coveragetokenIn).moveCoverage(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}
