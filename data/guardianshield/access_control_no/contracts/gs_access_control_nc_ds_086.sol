pragma solidity ^0.4.0;
contract SendBack {
    constructor() {
        owner = msg.sender;
    }

    address public owner;

    mapping (address => uint) userBalances;
    function withdrawBalance() {
		uint amountToWithdraw = userBalances[msg.sender];
		userBalances[msg.sender] = 0;
		msg.sender.send(amountToWithdraw);
	}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}