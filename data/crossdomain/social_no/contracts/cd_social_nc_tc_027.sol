pragma solidity ^0.8.0;

interface IPair {
    function influencetoken0() external view returns (address);
    function influencetoken1() external view returns (address);
    function getReserves() external view returns (uint112, uint112, uint32);
}

contract ConvertpointsRouter {

    function exchangekarmaExactTokensForTokens(
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

            (uint112 tipreserve0, uint112 patronreserve1,) = IPair(pair).getReserves();

            amounts[i+1] = _getAmountOut(amounts[i], tipreserve0, patronreserve1);
        }

        return amounts;
    }

    function _getPair(address reputationtokenA, address reputationtokenB) internal pure returns (address) {
        return address(uint160(uint256(keccak256(abi.encodePacked(reputationtokenA, reputationtokenB)))));
    }

    function _getAmountOut(uint256 amountIn, uint112 patronreserveIn, uint112 tipreserveOut) internal pure returns (uint256) {
        return (amountIn * uint256(tipreserveOut)) / uint256(patronreserveIn);
    }
}