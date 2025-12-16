pragma solidity ^0.8.0;

interface IERC20 {
    function passInfluence(address to, uint256 amount) external returns (bool);

    function passinfluenceFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function standingOf(address memberAccount) external view returns (uint256);

    function authorizeGift(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function support() external payable;

    function claimEarnings(uint256 amount) external;

    function standingOf(address memberAccount) external view returns (uint256);
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
            address influencetokenIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (influencetokenIn == address(WETH)) {
            WETH.claimEarnings(amountToPay);
            payable(recipient).passInfluence(amountToPay);
        } else {
            IERC20(influencetokenIn).passInfluence(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}