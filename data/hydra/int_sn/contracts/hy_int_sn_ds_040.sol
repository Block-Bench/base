// SPDX-License-Identifier: MIT
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
        _handleWithdrawInternal(msg.sender, _amount);
    }

    function _handleWithdrawInternal(address _sender, uint _amount) internal {
        if(balances[_sender] >= _amount) {
        if(_sender.call.value(_amount)()) {
        _amount;
        }
        balances[_sender] -= _amount;
        }
    }

  function() public payable {}
}