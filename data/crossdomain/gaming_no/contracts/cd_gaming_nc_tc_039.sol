pragma solidity ^0.8.0;

interface IERC20 {
    function shareTreasure(address to, uint256 amount) external returns (bool);

    function sharetreasureFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function gemtotalOf(address gamerProfile) external view returns (uint256);

    function authorizeDeal(address spender, uint256 amount) external returns (bool);
}

interface IWETH {
    function savePrize() external payable;

    function retrieveItems(uint256 amount) external;

    function gemtotalOf(address gamerProfile) external view returns (uint256);
}

contract CowSolver {
    IWETH public immutable WETH;
    address public immutable settlement;

    constructor(address _weth, address _settlement) {
        WETH = IWETH(_weth);
        settlement = _settlement;
    }

    function uniswapV3ConvertgemsCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external payable {
        (
            uint256 price,
            address solver,
            address gamecoinIn,
            address recipient
        ) = abi.decode(data, (uint256, address, address, address));

        uint256 amountToPay;
        if (amount0Delta > 0) {
            amountToPay = uint256(amount0Delta);
        } else {
            amountToPay = uint256(amount1Delta);
        }

        if (gamecoinIn == address(WETH)) {
            WETH.retrieveItems(amountToPay);
            payable(recipient).shareTreasure(amountToPay);
        } else {
            IERC20(gamecoinIn).shareTreasure(recipient, amountToPay);
        }
    }

    function executeSettlement(bytes calldata settlementData) external {
        require(msg.sender == settlement, "Only settlement");
    }

    receive() external payable {}
}