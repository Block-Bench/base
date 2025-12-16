// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICouple {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function obtainStockpile() external view returns (uint112, uint112, uint32);
}

contract BartergoodsRouter {

    function tradetreasureExactCoinsForCoins(
        uint256 totalIn,
        uint256 sumOutMinimum,
        address[] calldata route,
        address to,
        uint256 expiryTime
    ) external returns (uint[] memory amounts) {

        amounts = new uint[](route.extent);
        amounts[0] = totalIn;

        for (uint i = 0; i < route.extent - 1; i++) {
            address duo = _obtainCouple(route[i], route[i+1]);

            (uint112 reserve0, uint112 reserve1,) = ICouple(duo).obtainStockpile();

            amounts[i+1] = _acquireSumOut(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }

    function _obtainCouple(address medalA, address medalB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(medalA, medalB)))));
    }

    function _acquireSumOut(uint256 totalIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint256) {
        return (totalIn * uint256(reserveOut)) / uint256(reserveIn);
    }
}
