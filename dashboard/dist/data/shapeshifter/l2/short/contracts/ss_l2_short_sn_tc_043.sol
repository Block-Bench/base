// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address q, uint256 o) external returns (bool);

    function b(
        address from,
        address q,
        uint256 o
    ) external returns (bool);

    function d(address h) external view returns (uint256);

    function g(address i, uint256 o) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant OPERATION_CALL = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public c;

    function a(
        uint8[] memory f,
        uint256[] memory k,
        bytes[] memory p
    ) external payable returns (uint256 l, uint256 n) {
        require(
            f.length == k.length && k.length == p.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < f.length; i++) {
            if (f[i] == OPERATION_CALL) {
                (address j, bytes memory callData, , , ) = abi.m(
                    p[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                (bool e, ) = j.call{value: k[i]}(callData);
                require(e, "Call failed");
            }
        }

        return (0, 0);
    }
}
