// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function gamecoin0() external view returns (address);
    function realmcoin1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract SwaplootRouter {

    function convertgemsExactTokensForTokens(
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

            (uint112 lootreserve0, uint112 lootreserve1,) = IPair(pair).getReserves();

            amounts[i+1] = _getAmountOut(amounts[i], lootreserve0, lootreserve1);
        }

        return amounts;
    }

    function _getPair(address goldtokenA, address realmcoinB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(goldtokenA, realmcoinB)))));
    }

    function _getAmountOut(uint256 amountIn, uint112 lootreserveIn, uint112 lootreserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(lootreserveOut)) / uint256(lootreserveIn);
    }
}
