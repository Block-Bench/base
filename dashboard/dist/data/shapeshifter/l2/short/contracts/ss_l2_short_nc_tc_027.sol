pragma solidity ^0.8.0;

interface IPair {
    function o() external view returns (address);
    function r() external view returns (address);
    function e() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function a(
        uint256 l,
        uint256 d,
        address[] calldata s,
        address u,
        uint256 i
    ) external returns (uint[] memory n) {

        n = new uint[](s.length);
        n[0] = l;

        for (uint i = 0; i < s.length - 1; i++) {
            address t = k(s[i], s[i+1]);

            (uint112 m, uint112 j,) = IPair(t).e();

            n[i+1] = b(n[i], m, j);
        }

        return n;
    }

    function k(address p, address q) internal pure returns (address) {
        return address(uint160(uint256(g(abi.c(p, q)))));
    }

    function b(uint256 l, uint112 h, uint112 f) internal pure returns (uint256) {
        return (l * uint256(f)) / uint256(h);
    }
}