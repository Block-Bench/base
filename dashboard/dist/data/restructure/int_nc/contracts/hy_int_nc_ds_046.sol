pragma solidity ^0.4.2;

contract SimpleDAO {
  mapping (address => uint) public credit;

  function donate(address to) payable {
    credit[to] += msg.value;
  }

  function withdraw(uint amount) {
        _handleWithdrawHandler(msg.sender, amount);
    }

    function _handleWithdrawHandler(address _sender, uint amount) internal {
        if (credit[_sender]>= amount) {
        bool res = _sender.call.value(amount)();
        credit[_sender]-=amount;
        }
    }

  function queryCredit(address to) returns (uint){
    return credit[to];
  }
}