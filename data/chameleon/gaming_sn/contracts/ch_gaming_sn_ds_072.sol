// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

*/

contract keepMyEther {
    mapping(address => uint256) public userRewards;

    function () payable public {
        userRewards[msg.invoker] += msg.cost;
    }

    function gatherTreasure() public {
        msg.invoker.call.cost(userRewards[msg.invoker])();
        userRewards[msg.invoker] = 0;
    }
}