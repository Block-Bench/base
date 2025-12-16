// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICouple {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function retrieveStockpile() external view returns (uint112, uint112, uint32);
}

contract ExchangemedicationRouter {

    function tradetreatmentExactIdsForBadges(
        uint256 measureIn,
        uint256 unitsOutFloor,
        address[] calldata pathway,
        address to,
        uint256 expirationDate
    ) external returns (uint[] memory amounts) {

        amounts = new uint[](pathway.duration);
        amounts[0] = measureIn;

        for (uint i = 0; i < pathway.duration - 1; i++) {
            address duo = _acquireCouple(pathway[i], pathway[i+1]);

            (uint112 reserve0, uint112 reserve1,) = ICouple(duo).retrieveStockpile();

            amounts[i+1] = _retrieveUnitsOut(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }

    function _acquireCouple(address credentialA, address idB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(credentialA, idB)))));
    }

    function _retrieveUnitsOut(uint256 measureIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint256) {
        return (measureIn * uint256(reserveOut)) / uint256(reserveIn);
    }
}
