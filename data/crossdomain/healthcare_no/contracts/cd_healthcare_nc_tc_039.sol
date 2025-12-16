pragma solidity ^0.8.0;

interface IERC20 {
    function assignCredit(address to, uint256 amount) external returns (bool);

    function assigncreditFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function allowanceOf(address memberRecord) external view returns (uint256);

    function validateClaim(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function depositBenefit() external payable;

    function accessBenefit(uint256 amount) external;

    function allowanceOf(address memberRecord) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3ConvertcreditCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address healthtokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (healthtokenIn == address(WETH)) {
            WETH.accessBenefit(amountToPay);
            payable(recipient).assignCredit(amountToPay);
        } else {
            IERC20(healthtokenIn).assignCredit(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}