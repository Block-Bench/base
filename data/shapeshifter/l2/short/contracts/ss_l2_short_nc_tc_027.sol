pragma solidity ^0.8.0;

interface IPair {
    function p() external view returns (address);
    function o() external view returns (address);
    function e() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function a(
        uint256 l,
        uint256 c,
        address[] calldata t,
        address u,
        uint256 j
    ) external returns (uint[] memory n) {

        n = new uint[](t.length);
        n[0] = l;

        for (uint i = 0; i < t.length - 1; i++) {
            address s = k(t[i], t[i+1]);

            (uint112 m, uint112 i,) = IPair(s).e();

            n[i+1] = b(n[i], m, i);
        }

        return n;
    }

    function k(address q, address r) internal pure returns (address) {
        return address(uint160(uint256(h(abi.d(q, r)))));
    }

    function b(uint256 l, uint112 g, uint112 f) internal pure returns (uint256) {
        return (l * uint256(f)) / uint256(g);
    }
}