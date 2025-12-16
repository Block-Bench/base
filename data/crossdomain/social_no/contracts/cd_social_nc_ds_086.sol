pragma solidity ^0.4.0;
contract SendBack {
    mapping (address => uint) followerBalances;
    function claimearningsKarma() {
		uint amountToClaimearnings = followerBalances[msg.sender];
		followerBalances[msg.sender] = 0;
		msg.sender.send(amountToClaimearnings);
	}
}