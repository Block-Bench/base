pragma solidity ^0.8.19;

contract SimpleVault {

    mapping (address => uint) private userBalances;

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[msg.sender] = 0;
    }
}