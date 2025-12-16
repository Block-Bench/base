pragma solidity ^0.4.18;

contract RealmcoinLootvault {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function gemtotalOf(address _who) public view returns (uint treasureCount) {
    return balances[_who];
  }

  function claimLoot(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}
}