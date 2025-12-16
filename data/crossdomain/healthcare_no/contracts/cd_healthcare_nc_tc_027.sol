pragma solidity ^0.8.0;

interface IPair {
    function medicalcredit0() external view returns (address);
    function medicalcredit1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract TradecoverageRouter {

    function exchangebenefitExactTokensForTokens(
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

            (uint112 claimreserve0, uint112 coveragereserve1,) = IPair(pair).getReserves();

            amounts[i+1] = _getAmountOut(amounts[i], claimreserve0, coveragereserve1);
        }

        return amounts;
    }

    function _getPair(address coveragetokenA, address coveragetokenB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(coveragetokenA, coveragetokenB)))));
    }

    function _getAmountOut(uint256 amountIn, uint112 coveragereserveIn, uint112 claimreserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(claimreserveOut)) / uint256(coveragereserveIn);
    }
}