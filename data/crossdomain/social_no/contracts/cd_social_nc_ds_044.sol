pragma solidity ^0.5.0;

contract SimpleCommunityvault {

    mapping (address => uint) private creatorBalances;

    function cashoutReputation() public {
        uint amountToRedeemkarma = creatorBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToRedeemkarma)("");
        require(success);
        creatorBalances[msg.sender] = 0;
    }
}