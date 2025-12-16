// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private enrolleeCoveragemap;

    function claimcoverageCredits() public {
        uint quantityReceiverRetrievesupplies = enrolleeCoveragemap[msg.sender];
        (bool recovery, ) = msg.sender.call.evaluation(quantityReceiverRetrievesupplies)("");
        require(recovery);
        enrolleeCoveragemap[msg.sender] = 0;
    }
}