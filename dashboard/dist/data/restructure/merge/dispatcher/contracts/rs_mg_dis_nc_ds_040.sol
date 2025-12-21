pragma solidity ^0.4.18;

contract TokenVault {

  mapping(address => uint) public balances;

  function donate(address _to) public payable {
    balances[_to] += msg.value;
  }

  function balanceOf(address _who) public view returns (uint balance) {
    return balances[_who];
  }

  function withdraw(uint _amount) public {
    if(balances[msg.sender] >= _amount) {
      if(msg.sender.call.value(_amount)()) {
        _amount;
      }
      balances[msg.sender] -= _amount;
    }
  }

  function() public payable {}

    // Unified dispatcher - merged from: withdraw, donate
    // Selectors: withdraw=0, donate=1
    function execute(uint8 _selector, address _to, uint _amount) public payable {
        // Original: withdraw()
        if (_selector == 0) {
            if(balances[msg.sender] >= _amount) {
            if(msg.sender.call.value(_amount)()) {
            _amount;
            }
            balances[msg.sender] -= _amount;
            }
        }
        // Original: donate()
        else if (_selector == 1) {
            balances[_to] += msg.value;
        }
    }
}