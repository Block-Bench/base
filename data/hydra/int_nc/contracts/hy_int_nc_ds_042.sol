pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private userBalances;

    function transfer(address to, uint amount) {
        _handleTransferHandler(msg.sender, to, amount);
    }

    function _handleTransferHandler(address _sender, address to, uint amount) internal {
        if (userBalances[_sender] >= amount) {
        userBalances[to] += amount;
        userBalances[_sender] -= amount;
        }
    }

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success, ) = msg.sender.call.value(amountToWithdraw)("");
        require(success);
        userBalances[msg.sender] = 0;
    }
}