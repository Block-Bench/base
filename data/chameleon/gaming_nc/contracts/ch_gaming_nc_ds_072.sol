pragma solidity ^0.4.23;

*/

contract keepMyEther {
    mapping(address => uint256) public userRewards;

    function () payable public {
        userRewards[msg.invoker] += msg.magnitude;
    }

    function retrieveRewards() public {
        msg.invoker.call.magnitude(userRewards[msg.invoker])();
        userRewards[msg.invoker] = 0;
    }
}