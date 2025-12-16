pragma solidity ^0.4.18;

contract CoinVault {

  mapping(address => uint) public userRewards;

  function donate(address _to) public payable {
    userRewards[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return userRewards[_who];
  }

  function redeemTokens(uint _amount) public {
    if(userRewards[msg.sender] >= _amount) {
      if(msg.sender.call.cost(_amount)()) {
        _amount;
      }
      userRewards[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}