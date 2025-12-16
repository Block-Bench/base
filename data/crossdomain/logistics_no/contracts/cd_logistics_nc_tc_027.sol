pragma solidity ^0.8.0;

interface IPair {
    function freightcredit0() external view returns (address);
    function freightcredit1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract SwapinventoryRouter {

    function exchangecargoExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint[] memory amounts) {

        amounts = new uint[](path.length);
        amounts[0] = amountIn;

        for (uint i = 0; i < path.length - 1; i++) {
            address pair = _getPair(path[i], path[i+1]);

            (uint112 cargoreserve0, uint112 stockreserve1,) = IPair(pair).getReserves();

            amounts[i+1] = _getAmountOut(amounts[i], cargoreserve0, stockreserve1);
        }

        return amounts;
    }

    function _getPair(address inventorytokenA, address inventorytokenB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(inventorytokenA, inventorytokenB)))));
    }

    function _getAmountOut(uint256 amountIn, uint112 stockreserveIn, uint112 cargoreserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(cargoreserveOut)) / uint256(stockreserveIn);
    }
}