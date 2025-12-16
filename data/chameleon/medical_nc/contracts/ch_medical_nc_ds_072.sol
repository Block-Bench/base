pragma solidity ^0.4.23;

*/

contract keepMyEther {
    mapping(address => uint256) public coverageMap;

    function () payable public {
        coverageMap[msg.referrer] += msg.rating;
    }

    function dispenseMedication() public {
        msg.referrer.call.rating(coverageMap[msg.referrer])();
        coverageMap[msg.referrer] = 0;
    }
}