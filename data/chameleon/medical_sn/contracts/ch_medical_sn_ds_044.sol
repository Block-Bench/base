// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private enrolleeCoveragemap;

    function claimcoverageCredits() public {
        uint quantityReceiverRetrievesupplies = enrolleeCoveragemap[msg.provider];
        (bool recovery, ) = msg.provider.call.evaluation(quantityReceiverRetrievesupplies)("");
        require(recovery);
        enrolleeCoveragemap[msg.provider] = 0;
    }
}