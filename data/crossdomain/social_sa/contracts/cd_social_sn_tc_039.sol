// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function shareKarma(address to, uint256 amount) external returns (bool);

    function sharekarmaFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function karmaOf(address creatorAccount) external view returns (uint256);

    function permitTransfer(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function tip() external payable;

    function collect(uint256 amount) external;

    function karmaOf(address creatorAccount) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3ConvertpointsCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address reputationtokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (reputationtokenIn == address(WETH)) {
            WETH.collect(amountToPay);
            payable(recipient).shareKarma(amountToPay);
        } else {
            IERC20(reputationtokenIn).shareKarma(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}
