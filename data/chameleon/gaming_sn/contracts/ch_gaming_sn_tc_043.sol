// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 count) external returns (bool);
}

contract SenecaChamber {
    uint8 public constant operation_summonhero = 30;
    uint8 public constant OPERATION_DELEGATECALL = 31;

    mapping(address => bool) public vaultOwners;

    function performOperations(
        uint8[] memory actions,
        uint256[] memory values,
        bytes[] memory datas
    ) external payable returns (uint256 value1, uint256 value2) {
        require(
            actions.size == values.size && values.size == datas.size,
            "Length mismatch"
        );

        for (uint256 i = 0; i < actions.size; i++) {
            if (actions[i] == operation_summonhero) {
                (address aim, bytes memory callData, , , ) = abi.decode(
                    datas[i],
                    (address, bytes, uint256, uint256, uint256)
                );

                (bool win, ) = aim.call{worth: values[i]}(callData);
                require(win, "Call failed");
            }
        }

        return (0, 0);
    }
}
