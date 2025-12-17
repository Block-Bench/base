// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleTreasurevault {

    mapping (address => uint) private adventurerBalances;

    function claimlootLootbalance() public {
        uint amountToClaimloot = adventurerBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToClaimloot)("");
        require(success);
        adventurerBalances[msg.sender] = 0;
    }
}