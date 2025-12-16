// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function relocatecargoFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address cargoProfile) external view returns (uint256);

    function clearCargo(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function checkInCargo() external payable;

    function releaseGoods(uint256 amount) external;

    function stocklevelOf(address cargoProfile) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3SwapinventoryCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address inventorytokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (inventorytokenIn == address(WETH)) {
            WETH.releaseGoods(amountToPay);
            payable(recipient).relocateCargo(amountToPay);
        } else {
            IERC20(inventorytokenIn).relocateCargo(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}
