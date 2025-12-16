pragma solidity ^0.5.0;

contract SimpleGoldvault {

    mapping (address => uint) private gamerBalances;

    function collecttreasureLootbalance() public {
        uint amountToRedeemgold = gamerBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToRedeemgold)("");
        require(success);
        gamerBalances[msg.sender] = 0;
    }
}