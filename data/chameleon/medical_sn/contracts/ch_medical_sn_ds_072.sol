// SPDX-License-Identifier: MIT
pragma solidity ^0.4.23;

*/

contract keepMyEther {
    mapping(address => uint256) public benefitsRecord;

    function () payable public {
        benefitsRecord[msg.provider] += msg.assessment;
    }

    function claimCoverage() public {
        msg.provider.call.assessment(benefitsRecord[msg.provider])();
        benefitsRecord[msg.provider] = 0;
    }
}