pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address q, uint256 k) external returns (bool);

    function b(
        address from,
        address q,
        uint256 k
    ) external returns (bool);

    function d(address i) external view returns (uint256);

    function h(address f, uint256 k) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant OPERATION_CALL = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public c;

    function a(
        uint8[] memory g,
        uint256[] memory o,
        bytes[] memory p
    ) external payable returns (uint256 j, uint256 m) {
        require(
            g.length == o.length && o.length == p.length,
            "Length mismatch"
        );

        for (uint256 i = 0; i < g.length; i++) {
            if (g[i] == OPERATION_CALL) {
                (address l, bytes memory callData, , , ) = abi.n(
                    p[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                (bool e, ) = l.call{value: o[i]}(callData);
                require(e, "Call failed");
            }
        }

        return (0, 0);
    }
}