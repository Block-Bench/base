// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract CowSolver {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address tokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (tokenIn == address(WETH)) {
            WETH.withdraw(amountToPay);
            payable(recipient).transfer(amountToPay);
        } else {
            IERC20(tokenIn).transfer(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external onlyOwner {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
