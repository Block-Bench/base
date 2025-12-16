// SPDX-License-Identifier: MIT
pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function withdraw(uint amount) {
        _doWithdrawHandler(msg.sender, amount);
    }

    function _doWithdrawHandler(address _sender, uint amount) internal {
        if (credit[_sender]>= amount) {
        bool res = _sender.call.value(amount)();
        credit[_sender]-=amount;
        }
    }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}