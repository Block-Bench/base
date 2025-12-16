// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function karmatoken0() external view returns (address);
    function influencetoken1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract ConvertpointsRouter {

    function tradeinfluenceExactTokensForTokens(
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

            (uint112 tipreserve0, uint112 tipreserve1,) = IPair(pair).getReserves();

            amounts[i+1] = _getAmountOut(amounts[i], tipreserve0, tipreserve1);
        }

        return amounts;
    }

    function _getPair(address influencetokenA, address reputationtokenB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(influencetokenA, reputationtokenB)))));
    }

    function _getAmountOut(uint256 amountIn, uint112 tipreserveIn, uint112 tipreserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(tipreserveOut)) / uint256(tipreserveIn);
    }
}
