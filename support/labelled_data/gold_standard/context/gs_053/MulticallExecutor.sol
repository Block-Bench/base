// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title MulticallExecutor
 * @notice Isolated contract for executing arbitrary external calls
 * @dev This contract intentionally has NO token approvals or privileged roles
 *      It exists solely to execute untrusted external calls in isolation
 *      preventing attackers from accessing user token approvals
 */
contract MulticallExecutor {
    using Address for address;

    struct Call {
        address target;
        bytes data;
        uint256 value;
    }

    /**
     * @notice Execute multiple external calls
     * @param calls Array of calls to execute
     * @dev Since this contract has no approvals, arbitrary calls cannot steal funds
     */
    function executeMulticall(Call[] calldata calls) external payable {
        for (uint256 i = 0; i < calls.length; i++) {
            calls[i].target.functionCallWithValue(calls[i].data, calls[i].value);
        }
    }

    /**
     * @notice Sweep any ETH accidentally sent to this contract
     */
    function sweepETH(address recipient) external {
        (bool success, ) = recipient.call{value: address(this).balance}("");
        require(success, "ETH sweep failed");
    }

    /**
     * @notice Sweep any tokens accidentally sent to this contract
     */
    function sweepToken(IERC20 token, address recipient) external {
        token.transfer(recipient, token.balanceOf(address(this)));
    }

    receive() external payable {}
}