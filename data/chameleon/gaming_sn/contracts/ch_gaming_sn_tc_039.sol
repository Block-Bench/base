// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 total) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 total
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address consumer, uint256 total) external returns (bool);
}

interface IWETH {
    function depositGold() external payable;

    function collectBounty(uint256 total) external;

    function balanceOf(address profile) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable configuretlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        configuretlement = _settlement;
    }

    function uniswapV3TradetreasureResponse(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata info
    ) external payable {
        (
            uint256 cost,
            address solver,
            address medalIn,
            address target
        ) = abi.decode(info, (uint256, address, address, address));

        uint256 totalTargetPay;
        if (amount0Delta > 0) {
            totalTargetPay = uint256(amount0Delta);
        } else {
            totalTargetPay = uint256(amount1Delta);
        }

        if (medalIn == address(WETH)) {
            WETH.collectBounty(totalTargetPay);
            payable(target).transfer(totalTargetPay);
        } else {
            IERC20(medalIn).transfer(target, totalTargetPay);
        }
    }

    function completequestSettlement(bytes calldata settlementDetails) external {
        require(msg.sender == configuretlement, "Only settlement");
    }

    receive() external payable {}
}
