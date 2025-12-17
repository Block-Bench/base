// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract CrossFunctionGoldvault {

    mapping (address => uint) private championBalances;

    function shareTreasure(address to, uint amount) {
        if (championBalances[msg.sender] >= amount) {
            championBalances[to] += amount;
            championBalances[msg.sender] -= amount;
        }
    }

    function claimlootTreasurecount() public {
        uint amountToRedeemgold = championBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToRedeemgold)("");
        require(success);
        championBalances[msg.sender] = 0;
    }
}