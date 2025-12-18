pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address q, uint256 j) external returns (bool);

    function b(
        address from,
        address q,
        uint256 j
    ) external returns (bool);

    function d(address h) external view returns (uint256);

    function e(address f, uint256 j) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant OPERATION_CALL = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public c;

    function a(
        uint8[] memory i,
        uint256[] memory k,
        bytes[] memory p
    ) external payable returns (uint256 o, uint256 n) {
        require(
            i.length == k.length && k.length == p.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < i.length; i++) {
            if (i[i] == OPERATION_CALL) {
                (address l, bytes memory callData, , , ) = abi.m(
                    p[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                (bool g, ) = l.call{value: k[i]}(callData);
                require(g, "Call failed");
            }
        }

        return (0, 0);
    }
}