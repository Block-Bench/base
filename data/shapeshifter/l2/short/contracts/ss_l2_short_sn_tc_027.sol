// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPair {
    function p() external view returns (address);
    function o() external view returns (address);
    function e() external view returns (uint112, uint112, uint32);
}

contract SwapRouter {

    function a(
        uint256 j,
        uint256 d,
        address[] calldata t,
        address u,
        uint256 k
    ) external returns (uint[] memory n) {

        n = new uint[](t.length);
        n[0] = j;

        for (uint i = 0; i < t.length - 1; i++) {
            address s = l(t[i], t[i+1]);

            (uint112 m, uint112 i,) = IPair(s).e();

            n[i+1] = b(n[i], m, i);
        }

        return n;
    }

    function l(address r, address q) internal pure returns (address) {
        return address(uint160(uint256(g(abi.c(r, q)))));
    }

    function b(uint256 j, uint112 h, uint112 f) internal pure returns (uint256) {
        return (j * uint256(f)) / uint256(h);
    }
}
