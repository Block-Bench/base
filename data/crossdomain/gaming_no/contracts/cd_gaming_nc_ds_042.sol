pragma solidity ^0.4.24;

contract CrossFunctionGoldvault {

    mapping (address => uint) private gamerBalances;

    function sendGold(address to, uint amount) {
        if (gamerBalances[msg.sender] >= amount) {
            gamerBalances[to] += amount;
            gamerBalances[msg.sender] -= amount;
        }
    }

    function collecttreasureItemcount() public {
        uint amountToTakeprize = gamerBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToTakeprize)("");
        require(success);
        gamerBalances[msg.sender] = 0;
    }
}