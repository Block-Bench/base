pragma solidity ^0.8.0;

interface ICouple {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fetchBackup() external view returns (uint112, uint112, uint32);
}

contract BartergoodsRouter {

    function bartergoodsExactCrystalsForGems(
        uint256 countIn,
        uint256 sumOutFloor,
        address[] calldata route,
        address to,
        uint256 timeLimit
    ) external returns (uint[] memory amounts) {

        amounts = new uint[](route.size);
        amounts[0] = countIn;

        for (uint i = 0; i < route.size - 1; i++) {
            address couple = _acquireDuo(route[i], route[i+1]);

            (uint112 reserve0, uint112 reserve1,) = ICouple(couple).fetchBackup();

            amounts[i+1] = _fetchCountOut(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }

    function _acquireDuo(address crystalA, address gemB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(crystalA, gemB)))));
    }

    function _fetchCountOut(uint256 countIn, uint112 reserveIn, uint112 reserveOut) internal pure returns (uint256) {
        return (countIn * uint256(reserveOut)) / uint256(reserveIn);
    }
}